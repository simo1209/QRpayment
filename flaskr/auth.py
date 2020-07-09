import functools

from flask import (
    Blueprint, flash, g, redirect, render_template, request, session, url_for
)
from werkzeug.security import check_password_hash, generate_password_hash

from flaskr.db import DB

bp = Blueprint('auth', __name__, url_prefix='/auth')


@bp.route('/register', methods=['POST'])
def register():
    email = request.json['email']
    password = request.json['password']
    first_name = request.json['first_name']
    last_name = request.json['last_name']
    phone = request.json['phone']
    error = None

    with DB() as db:
        if not email:
            error = 'Email is required.'
        elif not password:
            error = 'Password is required.'
        elif not first_name:
            error = 'First Name is required.'
        elif not last_name:
            error = 'Last Name is required.'
        elif not phone:
            error = 'Phone is required.'    

        if email:
            db.execute(
                'SELECT id FROM accounts WHERE email = %s', (email,)
            )
        if db.fetchone() is not None:
            error = 'Account {} is already registered.'.format(email)

        if error is None:
            db.execute(
                'INSERT INTO accounts (email, password, first_name, last_name, phone) VALUES (%s, %s, %s, %s, %s)',
                (email, generate_password_hash(password), first_name, last_name, phone)
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
        if g.account is None:
            return "Need to login", 401

        return view(**kwargs)

    return wrapped_view
