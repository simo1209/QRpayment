import os

from flask import Flask
from flask import request

from . import db

import decimal
import flask.json


class CustomJSONEncoder(flask.json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            # Convert decimal instances to strings.
            return str(obj)
        return super(CustomJSONEncoder, self).default(obj)


def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)
    app.json_encoder = CustomJSONEncoder
    app.config.from_mapping(
        SECRET_KEY='dev',
        DATABASE='dbname=practise user=simo09',
    )

    if test_config is None:
        # load the instance config, if it exists, when not testing
        app.config.from_pyfile('config.py', silent=True)
    else:
        # load the test config if passed in
        app.config.from_mapping(test_config)

    # ensure the instance folder exists
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    db.init_app(app)

    from . import auth
    app.register_blueprint(auth.bp)

    from . import transaction
    app.register_blueprint(transaction.bp)

    from . import admin
    app.register_blueprint(admin.bp)

    return app
