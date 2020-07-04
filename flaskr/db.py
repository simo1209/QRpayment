import psycopg2
import psycopg2.pool

import click
from flask import current_app, g
from flask.cli import with_appcontext


def get_db():
    if 'db' not in g:
        g.db = psycopg2.pool.ThreadedConnectionPool(1,20,
            current_app.config['DATABASE']
        )

    return g.db

def init_db():
    db = get_db()

    with current_app.open_resource('schema.sql') as f: # Fix nested 'with' statements 
        with DB() as db:
            db.execute(f.read().decode('utf8'))

@click.command('init-db')
@with_appcontext
def init_db_command():
    """Clear the existing data and create new tables."""
    init_db()
    click.echo('Initialized the database.')

def close_db(e=None):
    db = g.pop('db', None)

    if db is not None:
        db.closeall()

def init_app(app):
    app.teardown_appcontext(close_db)
    app.cli.add_command(init_db_command)

class DB:
    def __enter__(self):
        self.connection = get_db().getconn()
        return self.connection.cursor()

    def __exit__(self, type, value, traceback):
        self.connection.commit()
        get_db().putconn(self.connection)