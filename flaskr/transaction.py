from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from flask import jsonify
from flask import session

from werkzeug.exceptions import abort

from flaskr.auth import login_required
from flaskr.db import DB

bp = Blueprint('transactions', __name__, url_prefix='/transactions')


@bp.route('/check', methods=['POST'])
@login_required
def check():
    transaction_data = request.json['data'].split(':')
    print(transaction_data)
    if transaction_data[0] != 'QRpayment':
        print('Unrecognized QR code')
        return 'Unrecognized QR code', 400
    transaction_id = transaction_data[-1]
    print(transaction_id)
    with DB() as db:
        db.execute(
            '''SELECT transactions.transaction_desc, 
                accounts.first_name AS sellers_name FROM transactions 
                LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE transactions.id = %s''',
            (transaction_id)
        )
        return jsonify(db.fetchone()), 200


@bp.route('/list', methods=['GET'])
@login_required
def list():
    with DB() as db:
        db.execute(
            '''SELECT transactions.id, transactions.transaction_desc, transactions.amount, 
                accounts.first_name AS sellers_name
                FROM transactions LEFT JOIN accounts on transactions.seller_id = accounts.id 
                WHERE buyer_id = %s OR seller_id = %s;''',
            (g.account['id'], g.account['id'])
        )
        return jsonify(db.fetchall())
