import remote_db_config as conf
import cx_Oracle
from sshtunnel import SSHTunnelForwarder
from pprint import pprint

from generate import Generator

with SSHTunnelForwarder((conf.tunnel_host, conf.tunnel_port), 
                         ssh_username=conf.ssh_user, 
                         ssh_pkey=conf.ssh_pkey, 
                         remote_bind_address=(conf.db_host, conf.db_port)) as tunnel:
    port = tunnel.local_bind_port
    
    try:
        conn = cx_Oracle.connect(conf.db_user, conf.db_password, 'localhost:%d/%s' % (port, conf.db_sid))
        cursor = conn.cursor()

        generator = Generator(conn, cursor)
        try:
            generator.delete_all_content()

            conferences = generator.create_conferences()
            generator.insert_conferences(conferences)

            conf_days = generator.create_conference_days(conferences)
            generator.insert_conference_days(conf_days)

            workshops = generator.create_workshops(conf_days)
            generator.insert_workshops(workshops)

            prices = generator.create_prices(conferences)
            generator.insert_prices(prices)

            private_clients = generator.create_private_clients()
            company_clients = generator.create_company_clients()
            clients = private_clients + company_clients
            generator.insert_clients(clients)

            attendees = generator.create_attendees()
            generator.insert_attendees(attendees)

            bookings = generator.create_bookings(conferences)
            conf_day_bookings = generator.create_conf_day_bookings(bookings, conf_days)
            bookings = generator.remove_empty_bookings(bookings, conf_day_bookings)

            generator.insert_bookings(bookings)
            generator.insert_conf_day_bookings(conf_day_bookings)

            cursor.execute("SELECT * FROM CONF_DAY_BOOKINGS")
            pprint(cursor.fetchmany(10))
        except cx_Oracle.DatabaseError as e:
            print('Database error upon execution: ' + str(e))
        finally:
            cursor.close()
            conn.close()
    except cx_Oracle.DatabaseError as e:
        print('Database connection error: ' + str(e))
