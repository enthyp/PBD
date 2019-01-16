import datetime as dt
import string
from random import randint
from random import choice, choices, sample
from faker import Faker
import cx_Oracle

class Generator:
    def __init__(self, conn, cursor):
        self._conn = conn
        self._cursor = cursor
        self._fake = Faker()
        self._fake.seed(1234)

    def _fake_email(self, salt: str):
        email = self._fake.email()
        login, domain = email.split('@')
        email = "{}{}@{}".format(login, salt, domain)
        return email[:255]

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
                if price == 1:
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

        for i in range(200):
            clients.append((i + 1000,
                            'N',
                            self._fake.first_name() + " " + self._fake.last_name(),
                            self._fake.country()[:50],
                            self._fake.city()[:50],
                            self._fake.street_address()[:100],
                            ''.join(choices(string.digits, k=9)),
                            self._fake_email(str(i)),
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
                            self._fake_email(str(i)),
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
            is_student = choice([True, False])
            attendees.append((i,
                              self._fake.first_name(),
                              self._fake.last_name(),
                              ''.join(choices(string.digits, k=10)) if is_student else None,
                              self._fake_email(str(i)),
                              ''.join(choices(string.digits, k=9))
                              ))
        return attendees

    def insert_attendees(self, attendees):
        self._cursor.executemany("INSERT INTO ATTENDEES"
                                 "(ATTENDEE_ID, FIRST_NAME, LAST_NAME, STUDENT_CARD, EMAIL, PHONE) "
                                 "VALUES(:1, :2, :3, :4, :5, :6)", attendees)
        self._conn.commit()

    @staticmethod
    def create_bookings(conferences):
        bookings = []

        i = 0
        for c in conferences:
            no_bookings = randint(80, 120)
            for _ in range(no_bookings):
                is_private = choice([True, False])
                bookings.append((i,
                                 randint(0, 199) + 1000 if is_private else randint(0, 99),
                                 c[0],
                                 'N', # for the sake of easy generation
                                 c[5] - dt.timedelta(randint(10, 30))))
                i += 1

        return bookings

    def insert_bookings(self, bookings):
        self._cursor.executemany("INSERT INTO BOOKINGS"
                                 "(BOOKING_ID, CLIENT_ID, CONFERENCE_ID, IS_CANCELLED, BOOKING_DATE) "
                                 "VALUES(:1, :2, :3, :4, :5)", bookings)
        self._conn.commit()

    @staticmethod
    def create_conf_day_bookings(bookings, conf_days):
        conf_day_bookings = []
        conf_day_limits = {cd[0]: cd[3] for cd in conf_days}

        i = 0
        for b in bookings:
            conf_id = b[2]
            conf_days_for_booking = [cd for cd in conf_days if cd[1] == conf_id]

            for cd in conf_days_for_booking:
                conf_day_id = cd[0]
                no_attendees = randint(0, min(10, conf_day_limits[conf_day_id]))
                if no_attendees > 0:
                    no_students = randint(0, no_attendees)
                    booking_id = b[0]
                    conf_day_limits[conf_day_id] -= no_attendees
                    conf_day_bookings.append((i,
                                              booking_id,
                                              conf_day_id,
                                              no_students,
                                              no_attendees,
                                              'N'))
                    i += 1
        return conf_day_bookings

    @staticmethod
    def remove_empty_bookings(bookings, conf_day_bookings):
        empty = set()
        for b in bookings:
            is_empty = len([cdb for cdb in conf_day_bookings if cdb[1] == b[0]]) == 0
            if is_empty:
                empty.add(b)
        return [b for b in bookings if b not in empty]

    def insert_conf_day_bookings(self, conf_day_bookings):
        self._cursor.executemany("INSERT INTO CONF_DAY_BOOKINGS"
                                 "(CONF_DAY_BOOKING_ID, BOOKING_ID, CONF_DAY_ID, NUMBER_OF_STUDENTS, "
                                 "NUMBER_OF_ATTENDEES, IS_CANCELLED) "
                                 "VALUES(:1, :2, :3, :4, :5, :6)", conf_day_bookings)
        self._conn.commit()

    @staticmethod
    def create_workshop_bookings(conf_day_bookings, workshops):
        workshop_bookings = []
        workshop_limits = {w[0]: w[6] for w in workshops}

        i = 0
        for cdb in conf_day_bookings:
            conf_day_id, students_max, attendees_max = cdb[2:5]
            conf_day_workshops = [w for w in workshops if w[1] == conf_day_id]
            for w in conf_day_workshops:
                workshop_id = w[0]
                no_attendees = randint(0, min(5, workshop_limits[workshop_id], attendees_max))
                if no_attendees > 0:
                    conf_day_booking_id = cdb[0]
                    no_students = randint(max((no_attendees - (attendees_max - students_max)), 0),
                                          min(students_max, no_attendees)) # CAREFUL!
                    workshop_limits[workshop_id] -= no_attendees
                    workshop_bookings.append((i,
                                              conf_day_booking_id,
                                              workshop_id,
                                              no_students,
                                              no_attendees,
                                              'N'))
                    i += 1

        return workshop_bookings

    def insert_workshop_bookings(self, workshop_bookings):
        self._cursor.executemany("INSERT INTO WORKSHOP_BOOKINGS"
                                 "(WORKSHOP_BOOKING_ID, CONF_DAY_BOOKING_ID, WORKSHOP_ID, NUMBER_OF_STUDENTS, "
                                 "NUMBER_OF_ATTENDEES, IS_CANCELLED) "
                                 "VALUES(:1, :2, :3, :4, :5, :6)", workshop_bookings)
        self._conn.commit()

    @staticmethod
    def create_conf_day_participation(conf_day_bookings, attendees):
        conf_day_participation = []
        students = [a for a in attendees if a[3] is not None]
        adults = [a for a in attendees if a[3] is None]

        i = 0
        for cdb in conf_day_bookings:
            booking_id, conf_day_id, no_students, no_attendees = cdb[1:5]
            student_participants = sample(students, no_students)
            adult_participants = sample(adults, no_attendees - no_students)

            for j in range(no_students):
                conf_day_participation.append((i,
                                               conf_day_id,
                                               student_participants[j][0],
                                               booking_id,
                                               'Y'))
                i += 1

            for j in range(no_attendees - no_students):
                conf_day_participation.append((i,
                                               conf_day_id,
                                               adult_participants[j][0],
                                               booking_id,
                                               'N'))
                i += 1

        return conf_day_participation

    def insert_conf_day_participation(self, conf_day_participation):
        self._cursor.executemany("INSERT INTO PARTICIPATION_CONF_DAYS"
                                 "(PARTICIPATION_CONF_DAY_ID, CONF_DAY_ID, ATTENDEE_ID, "
                                 "BOOKING_ID, IS_STUDENT) "
                                 "VALUES(:1, :2, :3, :4, :5)", conf_day_participation)
        self._conn.commit()

    def create_workshop_participation(self, workshop_bookings):
        workshop_participation = []

        # Prepare two maps: from workshop booking IDs to potential student and adult participants, respectively.
        self._cursor.execute("SELECT WB.WORKSHOP_BOOKING_ID, PCD.PARTICIPATION_CONF_DAY_ID, PCD.IS_STUDENT "
                             "FROM PARTICIPATION_CONF_DAYS PCD "
                             "JOIN CONF_DAY_BOOKINGS CDB ON CDB.BOOKING_ID = PCD.BOOKING_ID "
                             "AND CDB.CONF_DAY_ID = PCD.CONF_DAY_ID "
                             "JOIN WORKSHOP_BOOKINGS WB ON WB.CONF_DAY_BOOKING_ID = CDB.CONF_DAY_BOOKING_ID")
        workshop_potential_participants = self._cursor.fetchall()

        student_pp = [t for t in workshop_potential_participants if t[2] == 'Y']
        adult_pp = [t for t in workshop_potential_participants if t[2] == 'N']

        student_participation = {t[0]: [] for t in workshop_potential_participants}
        adult_participation = {t[0]: [] for t in workshop_potential_participants}

        for spp in student_pp:
            student_participation[spp[0]].append(spp[1])

        for app in adult_pp:
            adult_participation[app[0]].append(app[1])

        i = 0
        for wb in workshop_bookings:
            workshop_booking_id, conf_day_booking_id, workshop_id, no_students, no_attendees = wb[:5]
            student_participants = sample(student_participation[workshop_booking_id], no_students)
            adult_participants = sample(adult_participation[workshop_booking_id], no_attendees - no_students)

            for j in range(no_students):
                workshop_participation.append((i, workshop_id, student_participants[j]))
                i += 1

            for j in range(no_attendees - no_students):
                workshop_participation.append((i, workshop_id, adult_participants[j]))
                i += 1

        return workshop_participation

    def insert_workshop_participation(self, workshop_participation):
        self._cursor.executemany("INSERT IGNORE INTO PARTICIPATION_WORKSHOPS"
                                 "(PARTICIPATION_WORKSHOP_ID, WORKSHOP_ID, PARTICIPATION_CONF_DAY_ID) "
                                 "VALUES(:1, :2, :3)", workshop_participation)
        self._conn.commit() # TODO: overlap?
