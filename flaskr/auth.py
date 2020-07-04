import functools

from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)
from werkzeug.security import check_password_hash, generate_password_hash

from flaskr.db import DB

bp = Blueprint('auth', __name__, url_prefix='/auth')


@bp.route('/register', methods=['POST'])
def register():
    email = request.authorization['username']
    password = request.authorization['password']
    error = None

    with DB() as db:
        if not email:
            error = 'email is required.'
        elif not password:
            error = 'Password is required.'

        db.execute(
            'SELECT id FROM accounts WHERE email = %s', (email,)
        )
        if db.fetchone() is not None:
            error = 'User {} is already registered.'.format(email)

        if error is None:
            db.execute(
                'INSERT INTO accounts (email, password) VALUES (%s, %s)',
                (email, generate_password_hash(password))
            )
            return "Successful", 201
        return error, 400


@bp.route('/login', methods=['POST'])
def login():
    email = request.authorization['username']
    password = request.authorization['password']
    error = None

    with DB() as db:
        db.execute(
            'SELECT * FROM accounts WHERE email = %s', (email,)
        )
        account = db.fetchone()

    if account is None:
        error = 'Incorrect email.'
    elif not check_password_hash(account['password'], password):
        error = 'Incorrect password.'

    if error is None:
        session.clear()
        session['account_id'] = account['id']
        return 'Successful', 200
    return error, 401


@bp.before_app_request
def load_logged_in_user():
    account_id = session.get('account_id')

    if account_id is None:
        g.account = None
    else:
        with DB() as db:
            db.execute(
                'SELECT * FROM accounts WHERE id = %s', (account_id,)
            )
            g.account = db.fetchone()


@bp.route('/logout')
def logout():
    session.clear()
    return "Logged Out", 200


def login_required(view):
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('auth.login'))

        return view(**kwargs)

    return wrapped_view
