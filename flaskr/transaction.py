from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from flask import jsonify
from flask import session
from flask import send_file

from werkzeug.exceptions import abort

from flaskr.auth import login_required
from flaskr.db import DB

import qrcode

bp = Blueprint('transactions', __name__, url_prefix='/transactions')


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
            img = qrcode.make('QRpayment:{}'.format(id))
            img.save('qr-codes/{}.png'.format(id))
            return send_file('../qr-codes/{}.png'.format(id))
    return error, 400


@bp.route('/check', methods=['POST'])
@login_required
def check():
    transaction_data = request.json['data'].split(':')
    if transaction_data[0] != 'QRpayment':
        print('Unrecognized QR code')
        return 'Unrecognized QR code', 400
    transaction_id = transaction_data[-1]
    with DB() as db:
        db.execute(
            '''SELECT transactions.id, transactions.transaction_desc, transactions.amount,
                accounts.first_name AS seller_name FROM transactions 
                LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE transactions.id = %s''',
            (transaction_id)
        )
        return jsonify(db.fetchone()), 200


@bp.route('/accept', methods=['POST'])
@login_required
def accept():

    id = request.json['id']
    error = None
    if not id:
        error = "SUpply id"

    if error is None:
        with DB() as db:
            db.execute(
                '''UPDATE transactions
                    SET buyer_id = %s, status = 'Completed'
                    WHERE id = %s;''',
                    (g.account['id'], id))
            return "Accepted", 201
    return error, 400

@bp.route('/list', methods=['GET'])
@login_required
def list():
    with DB() as db:
        db.execute(
            '''SELECT transactions.id, transactions.transaction_desc, transactions.amount, 
                accounts.first_name AS seller_name
                FROM transactions LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE buyer_id = %s OR seller_id = %s;''',
            (g.account['id'], g.account['id'])
        )
        return jsonify(db.fetchall())
