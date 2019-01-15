import datetime as dt
import string
from random import randint
from random import choices
from faker import Faker
from pprint import pprint

class Generator:
    def __init__(self, conn, cursor):
        self._conn = conn
        self._cursor = cursor
        self._fake = Faker()
        self._fake.seed(1234)


    def delete_all_content(self):
        self._cursor.execute("DELETE FROM PARTICIPATION_WORKSHOPS")
        self._cursor.execute("DELETE FROM WORKSHOP_BOOKINGS")
        self._cursor.execute("DELETE FROM WORKSHOPS")
        self._cursor.execute("DELETE FROM CONF_DAY_BOOKINGS")
        self._cursor.execute("DELETE FROM PARTICIPATION_CONF_DAYS")
        self._cursor.execute("DELETE FROM CONFERENCE_DAYS")
        self._cursor.execute("DELETE FROM PRICES")
        self._cursor.execute("DELETE FROM PAYMENTS")
        self._cursor.execute("DELETE FROM BOOKINGS")
        self._cursor.execute("DELETE FROM CONFERENCES")
        self._cursor.execute("DELETE FROM CLIENTS")
        self._cursor.execute("DELETE FROM ATTENDEES")
        self._conn.commit()

    def create_conferences(self):
        conferences = []

        i = 0
        date = dt.datetime(2015, 7, 12)
        while date < dt.datetime(2018, 7, 12):
            date += dt.timedelta(randint(10, 20))
            conferences.append((i,
                                self._fake.sentence(nb_words=3, variable_nb_words=True),
                                self._fake.country(),
                                self._fake.city(),
                                self._fake.street_address(),
                                date,
                                date + dt.timedelta(randint(2, 3)),
                                randint(0, 50)))
            i += 1
        return conferences

    def insert_conferences(self, conferences):
        self._cursor.executemany("INSERT INTO CONFERENCES"
                                 "(CONFERENCE_ID, CONFERENCE_NAME, COUNTRY, CITY, ADDRESS, FIRST_DAY, LAST_DAY, STUDENT_DISCOUNT) "
                                 "VALUES(:1, :2, :3, :4, :5, :6, :7, :8)", conferences)
        self._conn.commit()

    @staticmethod
    def create_conference_days(conferences):
        conf_days = []

        i = 0
        for c in conferences:
            start_date = c[5]
            end_date = c[6]
            step = dt.timedelta(days=1)
            while start_date <= end_date:
                price = randint(100, 10000) / 100.0
                limit = randint(200, 300)
                conf_days.append((i, c[0], price, limit, start_date))
                start_date += step
                i += 1
        return conf_days

    def insert_conference_days(self, conf_days):
        self._cursor.executemany("INSERT INTO CONFERENCE_DAYS(CONF_DAY_ID, CONFERENCE_ID, PRICE, LIMIT, DAY_DATE) "
                                 "VALUES(:1, :2, :3, :4, :5)", conf_days)
        self._conn.commit()

    def create_workshops(self, conf_days):
        workshops = []

        i = 0
        for cd in conf_days:
            no_workshops = randint(3, 5)

            for _ in range(no_workshops):
                price = randint(0, 1)
                if price == 0:
                    price = randint(100, 10000) / 100.0
                start_time = dt.datetime.combine(cd[4], dt.time(randint(8, 18), randint(0, 5)*10))
                duration = dt.timedelta(minutes=randint(3, 10)*10)
                workshops.append((i,
                                  cd[0],
                                  self._fake.sentence(nb_words=4, variable_nb_words=True),
                                  start_time,
                                  start_time + duration,
                                  price,
                                  randint(5, 30)))
                i += 1

        return workshops

    def insert_workshops(self, workshops):
        self._cursor.executemany("INSERT INTO WORKSHOPS"
                                 "(WORKSHOP_ID, CONF_DAY_ID, WORKSHOP_NAME, START_TIME, END_TIME, PRICE, LIMIT) "
                                 "VALUES(:1, :2, :3, :4, :5, :6, :7)", workshops)
        self._conn.commit()

    @staticmethod
    def create_prices(conferences):
        prices = []

        i = 0
        for c in conferences:
            no_prices = randint(0, 3)
            discount = randint(10, 50)
            advance = dt.timedelta(randint(10, 30))
            end_date = c[5] - advance
            for j in range(no_prices):
                prices.append((i, c[0], discount, end_date))
                discount -= randint(1, discount//2)
                end_date += dt.timedelta(randint(1, (c[5] - end_date).days//2))
                i += 1
        return prices

    def insert_prices(self, prices):
        self._cursor.executemany("INSERT INTO PRICES"
                                 "(PRICE_ID, CONFERENCE_ID, DISCOUNT, END_DATE) "
                                 "VALUES(:1, :2, :3, :4)", prices)
        self._conn.commit()

    def create_private_clients(self):
        clients = []

        for i in range(100):
            clients.append((i + 1000,
                            'N',
                            self._fake.first_name() + " " + self._fake.last_name(),
                            self._fake.country()[:50],
                            self._fake.city()[:50],
                            self._fake.street_address()[:100],
                            ''.join(choices(string.digits, k=9)),
                            self._fake.email()[:255],
                            ''.join(choices(string.ascii_letters + string.digits, k=randint(16, 100)))
                            ))
        return clients

    def create_company_clients(self):
        clients = []

        for i in range(100):
            clients.append((i,
                            'Y',
                            self._fake.sentence(nb_words=2, variable_nb_words=True),
                            self._fake.country()[:50],
                            self._fake.city()[:50],
                            self._fake.street_address()[:100],
                            ''.join(choices(string.digits, k=9)),
                            self._fake.email()[:255],
                            ''.join(choices(string.ascii_letters + string.digits, k=randint(16, 100)))
                            ))
        return clients

    def insert_clients(self, clients):
        self._cursor.executemany(" INSERT INTO CLIENTS"
                                 "(CLIENT_ID, IS_COMPANY, CLIENT_NAME, COUNTRY, CITY, ADDRESS, PHONE, EMAIL, PASSWORD) "
                                 "VALUES(:1, :2, :3, :4, :5, :6, :7, :8, :9)", clients)
        self._conn.commit()

    def create_attendees(self):
        attendees = []

        for i in range(2000):
            is_student = True if randint(1, 10) < 3 else False
            email = self._fake.email()
            login, domain = email.split('@')
            email = "{}{}@{}".format(login, i, domain)
            attendees.append((i,
                              self._fake.first_name(),
                              self._fake.last_name(),
                              ''.join(choices(string.digits, k=10)) if is_student else None,
                              email,
                              ''.join(choices(string.digits, k=9))
                              ))
        return attendees

    def insert_attendees(self, attendees):
        self._cursor.executemany("INSERT INTO ATTENDEES"
                                 "(ATTENDEE_ID, FIRST_NAME, LAST_NAME, STUDENT_CARD, EMAIL, PHONE) "
                                 "VALUES(:1, :2, :3, :4, :5, :6)", attendees)

# Conferences first, independent of all.
# Add conference days to each, then workshops to some of conference days.
# Add price thresholds.
# Clients next, institutional and personal separately. For personal create appropriate attendees.
# Create a bunch of attendees.
# Create bookings of clients for different conferences.
# For each booking add some conference day bookings and workshop bookings - distinguish institutional and personal -
    # - a person can only reserve one place and must give attendee data immediately.
# Finally for all the bookings add participation. Maybe map groups of attendees to conference bookings? Guess not...