from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)

from flaskr.db import DB


bp = Blueprint('admin', __name__, url_prefix='/admin')


@bp.route('/transactions', methods = ['GET'])
def list():
    with DB() as db:
        db.execute(
            '''SELECT t.id, t.time_completed, t.transaction_desc as description, t.amount, a1.first_name || ' ' || a1.last_name as buyer, a2.first_name || ' ' || a2.last_name as seller
                FROM transactions t
                JOIN accounts a1 on t.buyer_id = a1.id
                JOIN accounts a2 on t.seller_id = a2.id;'''
        )
        transactions = db.fetchall()
        print(transactions)
        return render_template('transactions.html', transactions = transactions)