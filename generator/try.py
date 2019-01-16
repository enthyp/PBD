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
            print("{} conferences inserted...".format(len(conferences)))

            conf_days = generator.create_conference_days(conferences)
            generator.insert_conference_days(conf_days)
            print("{} conference days inserted...".format(len(conf_days)))

            workshops = generator.create_workshops(conf_days)
            generator.insert_workshops(workshops)
            print("{} workshops inserted...".format(len(workshops)))

            prices = generator.create_prices(conferences)
            generator.insert_prices(prices)
            print("{} prices inserted...".format(len(prices)))

            private_clients = generator.create_private_clients()
            company_clients = generator.create_company_clients()
            clients = private_clients + company_clients
            generator.insert_clients(clients)
            print("{} clients inserted...".format(len(clients)))

            attendees = generator.create_attendees()
            generator.insert_attendees(attendees)
            print("{} attendees inserted...".format(len(attendees)))

            bookings = generator.create_bookings(conferences)
            conf_day_bookings = generator.create_conf_day_bookings(bookings, conf_days)
            bookings = generator.remove_empty_bookings(bookings, conf_day_bookings)

            generator.insert_bookings(bookings)
            print("{} conference bookings inserted...".format(len(bookings)))
            generator.insert_conf_day_bookings(conf_day_bookings)
            print("{} conference day bookings inserted...".format(len(conf_day_bookings)))

            workshop_bookings = generator.create_workshop_bookings(conf_day_bookings, workshops)
            generator.insert_workshop_bookings(workshop_bookings)
            print("{} workshop bookings inserted...".format(len(workshop_bookings)))

            conf_day_participation = generator.create_conf_day_participation(conf_day_bookings, attendees)
            generator.insert_conf_day_participation(conf_day_participation)
            print("{} conference day participation relations inserted...".format(len(conf_day_participation)))

            workshop_participation = generator.create_workshop_participation(workshop_bookings)
            generator.insert_workshop_participation(workshop_participation)
            print("{} workshop participation relations inserted...".format(len(workshop_participation)))

            print("All data inserted.")

            cursor.execute("SELECT * FROM WORKSHOP_BOOKINGS")
            pprint(cursor.fetchmany(10))
        except cx_Oracle.DatabaseError as e:
            print('Database error upon execution: ' + str(e))
        finally:
            cursor.close()
            conn.close()
    except cx_Oracle.DatabaseError as e:
        print('Database connection error: ' + str(e))
