#!/usr/bin/env python3
import remote_db_config as conf
import cx_Oracle
from sshtunnel import SSHTunnelForwarder
from pprint import pprint

with SSHTunnelForwarder((conf.tunnel_host, conf.tunnel_port), 
                         ssh_username=conf.ssh_user, 
                         ssh_pkey=conf.ssh_pkey, 
                         remote_bind_address=(conf.db_host, conf.db_port)) as tunnel:
    port = tunnel.local_bind_port
    
    try:
        db = cx_Oracle.connect(conf.db_user, conf.db_password, 
            f'localhost:{port}/{conf.db_sid}')
        cursor = db.cursor()
        
        try:
            cursor.execute('INSERT INTO ATTENDEES (FIRST_NAME, LAST_NAME, EMAIL) ' + 
                "VALUES ('John', 'Doe', 'johnny@buziaczek.com')")
            db.commit()            
            cursor.execute('SELECT * FROM ATTENDEES')
            pprint(cursor.fetchall())
        except cx_Oracle.DatabaseError as e:
            print(f'Database error upon execution: {e}')
        finally:
            cursor.close()
            db.close()
    except cx_Oracle.DatabaseError as e:
        print(f'Database connection error: {e}')


