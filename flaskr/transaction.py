from flask import (
    Blueprint, flash, g, redirect, render_template, request, url_for
)
from flask import jsonify
from flask import session

from werkzeug.exceptions import abort

from flaskr.auth import login_required
from flaskr.db import DB

bp = Blueprint('transactions', __name__, url_prefix='/transactions')



@bp.route('/list', methods = ['GET'])
@login_required
def list():
    with DB() as db:
        db.execute(
            'SELECT id, transaction_desc FROM transactions WHERE buyer_id = %s OR seller_id = %s;',
            (g.account['id'],g.account['id'])
        )
        return jsonify(db.fetchall())