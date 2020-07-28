from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from flask import jsonify
from flask import session
from flask import send_file

from werkzeug.exceptions import abort

from flaskr.auth import login_required
from flaskr.db import DB

import pprint
import qrcode
from cryptography.fernet import Fernet

key_file = open('qrpayment.key', 'rb')
key = key_file.read()
fernet = Fernet(key)

bp = Blueprint('transactions', __name__, url_prefix='/transactions')

pp = pprint.PrettyPrinter(indent=4)

class Transaction:
    def __init__(self, id, buyer_id, seller_id, transaction_desc, status, time_completed, amount):
        self.id = id
        self.buyer_id = buyer_id
        self.seller_id = seller_id
        self.transaction_desc = transaction_desc
        self.status = transaction_desc
        self.time_completed = time_completed
        self.amount = amount

    @staticmethod
    def all():
        with DB() as db:
            db.execute('SELECT * FROM transactions;')
            rows = db.fetchall()
            return [Transaction(*row) for row in rows]

    @staticmethod
    def find(id):
        with DB() as db:
            db.execute(
                'SELECT * FROM transactions WHERE id = ?',
                (id,)
            )
            row = db.fetchone()
            return Transaction(*row)

    def save(self):
        with DB() as db:
            values = (
                self.buyer_id,
                self.seller_id,
                self.transaction_desc,
                self.status,
                self.amount,
                self.id
            )
            db.execute(
                '''UPDATE transactions
                SET buyer_id = ?, seller_id = ?, transaction_desc = ?, status = ?, amount = ?
                WHERE id = ?''', values)
            return self

    def delete(self):
        with DB() as db:
            db.execute('DELETE FROM transactions WHERE id = ?', (self.id,))


@bp.route('/create', methods=['POST'])
@login_required
def create():
    transcation_desc = request.json['transaction_desc']
    amount = float(request.json['amount'])
    error = None

    if not transcation_desc:
        error = "Transaction Description must"
    if not amount or amount <= 0:
        error = "Amount shouldn't be negative"

    if error is None:
        with DB() as db:
            db.execute("INSERT INTO transactions(seller_id, transaction_desc, amount, status) VALUES (%s, %s, %s, 'Pending') RETURNING id;",
                       (g.account['id'], transcation_desc, amount))
            id = db.fetchone()['id']
            if id is not None:
                code = ('QRpayment:{}'.format(id)).encode()
                img = qrcode.make(fernet.encrypt(code))
                print('saving qr code')
                img.save('{}.png'.format(id))
                return '/transactions/{}'.format(id), 201
    return error, 400


@bp.route('/<transaction_id>', methods=['GET'])
@login_required
def transaction_code(transaction_id):
    try:
        t_id = int(transaction_id)
    except ValueError:
        return 'Id is invalid', 400
    with DB() as db:
        db.execute('SELECT seller_id FROM transactions WHERE id = %s;',
                   [t_id])
        transaction = db.fetchone()
        if transaction is not None:
            if g.account['id'] != transaction['seller_id']:
                return 'Unathorized', 403
            return send_file('{}.png'.format(transaction_id))
    return 'Id is invalid', 400


@bp.route('/check', methods=['POST'])
@login_required
def check():
    transaction_data = request.json['data']
    decrypted = fernet.decrypt(transaction_data.encode()).decode()
    code = decrypted.split(':')
    if code[0] != 'QRpayment':
        print('Unrecognized QR code')
        return 'Unrecognized QR code', 400
    transaction_id = code[-1]
    print(transaction_id)
    with DB() as db:
        db.execute(
            '''SELECT transactions.id, transactions.transaction_desc, transactions.amount,
                accounts.first_name AS seller_name, transactions.status FROM transactions 
                LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE transactions.id = %s''',
            [transaction_id]
        )
        transaction = db.fetchone()
        if transaction['status'] == "Pending":
            return jsonify(transaction), 200
        else:
            return "Transaction is either already complete or invalid", 403


@bp.route('/accept', methods=['POST'])
@login_required
def accept():

    id = request.json['id']
    error = None
    if not id:
        error = "Supply id"

    if error is None:
        with DB() as db:

            db.execute(
                'SELECT seller_id,amount FROM transactions WHERE id = %s', (id))
            transaction = db.fetchone()

            transaction_amount = transaction['amount']

            db.execute('SELECT balance FROM accounts;')
            account_balance = db.fetchone()['balance']
            print(account_balance)

            if transaction_amount > account_balance:
                return "Account balance insufficient", 403

            db.execute(
                '''UPDATE accounts SET balance = balance - %s WHERE id = %s''',
                (transaction_amount, g.account['id'])
            )

            db.execute(
                '''UPDATE accounts SET balance = balance + %s WHERE id = %s''',
                (transaction_amount, transaction['seller_id'])
            )

            db.execute(
                '''UPDATE transactions
                    SET buyer_id = %s, status = 'Completed'
                    WHERE id = %s;''',
                (g.account['id'], id))

            # Return users new balance
            return jsonify({'balance': (account_balance-transaction_amount)}), 201
    return error, 400

@bp.route('/authorize', methods=['POST'])
def paypal_authorize():
    order = request.json
    pp.pprint(order)
    print('\n')
    if order and order['event_type'] == 'CHECKOUT.ORDER.APPROVED':
        resource = order['resource']
        pp.pprint(resource)
        print(resource['id'])
        payer = resource['payer']
        payer_email = payer['email_address']
        print('Unit')
        purchase_unit = resource['purchase_units'][0]
        print(purchase_unit)

        amount = purchase_unit['amount']
        print('Amount')
        print(amount)

        value = amount['value']

        print(payer_email)
        print('Updating balance')
        with DB() as db:
            db.execute('''UPDATE accounts SET 
                balance = balance + %s
                WHERE email = %s;''',
                [value, payer_email] )
        return "Successful", 200
    return "Failiure", 400

@bp.route('/list', methods=['GET'])
@login_required
def list():
    with DB() as db:
        db.execute(
            '''SELECT transactions.id, transactions.transaction_desc, transactions.amount, 
                accounts.first_name AS seller_name, transactions.status
                FROM transactions LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE buyer_id = %s OR seller_id = %s;''',
            (g.account['id'], g.account['id'])
        )
        return jsonify(db.fetchall())

@bp.route('/loadfunds', methods = ['GET'])
def load_funds():
    return render_template('load_money.html')

@bp.route('/loadfundcomplete', methods = ['GET'])
def load_funds_complete():
    return render_template('load_money_complete.html')