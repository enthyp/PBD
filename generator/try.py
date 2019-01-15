import remote_db_config as conf
import cx_Oracle
from sshtunnel import SSHTunnelForwarder
#from pprint import pprint

from generate import delete_all_content

with SSHTunnelForwarder((conf.tunnel_host, conf.tunnel_port), 
                         ssh_username=conf.ssh_user, 
                         ssh_pkey=conf.ssh_pkey, 
                         remote_bind_address=(conf.db_host, conf.db_port)) as tunnel:
    port = tunnel.local_bind_port
    
    try:
        conn = cx_Oracle.connect(conf.db_user, conf.db_password, 'localhost:%d/%s' % (port, conf.db_sid))
        cursor = conn.cursor()
        
        try:
            delete_all_content(conn, cursor)
            # cursor.execute('INSERT INTO ATTENDEES (FIRST_NAME, LAST_NAME, EMAIL) ' +
            #     "VALUES ('Joe', 'Doe', 'joe@buziaczek.com')")
            # conn.commit()
            #cursor.execute('SELECT * FROM ATTENDEES')
            #pprint(cursor.fetchall())
        except cx_Oracle.DatabaseError as e:
            print('Database error upon execution: ' + str(e))
        finally:
            cursor.close()
            conn.close()
    except cx_Oracle.DatabaseError as e:
        print('Database connection error: ' + str(e))
