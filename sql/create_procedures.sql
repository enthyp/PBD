/* PROCEDURES */
CREATE OR REPLACE PROCEDURE UPDATE_CLIENT(i_client_ID IN CLIENTS.CLIENT_ID%TYPE,
i_client_name IN CLIENTS.CLIENT_NAME%TYPE DEFAULT NULL,
i_country IN CLIENTS.COUNTRY%TYPE DEFAULT NULL,
i_city IN CLIENTS.CITY%TYPE DEFAULT NULL,
i_address IN CLIENTS.ADDRESS%TYPE DEFAULT NULL,
i_phone IN CLIENTS.PHONE%TYPE DEFAULT NULL,
i_email IN CLIENTS.EMAIL%TYPE DEFAULT NULL,
i_password IN CLIENTS.PASSWORD%TYPE DEFAULT NULL)
AS
BEGIN
  IF NOT CHECK_CLIENT_EXISTS(i_client_ID) THEN
    RAISE_APPLICATION_ERROR(-20402, 'Wrong client ID!');
  ELSE
    UPDATE CLIENTS
    SET CLIENT_NAME = NVL(i_client_name, CLIENT_NAME),
        COUNTRY     = NVL(i_country, COUNTRY),
        CITY        = NVL(i_city, CITY),
        ADDRESS     = NVL(i_address, ADDRESS),
        PHONE       = NVL(i_phone, PHONE),
        EMAIL       = NVL(i_email, EMAIL),
        PASSWORD    = NVL(i_password, PASSWORD)
    WHERE CLIENT_ID = i_client_ID;
  END IF;
END;

CREATE OR REPLACE PROCEDURE ADD_CONFERENCE(
  i_conf_name IN CONFERENCES.CONFERENCE_NAME%TYPE,
  i_country IN CONFERENCES.COUNTRY%TYPE,
  i_city IN CONFERENCES.CITY%TYPE,
  i_address IN CONFERENCES.ADDRESS%TYPE,
  i_first_day IN CONFERENCES.FIRST_DAY%TYPE,
  i_last_day IN CONFERENCES.LAST_DAY%TYPE,
  i_student_discount IN CONFERENCES.STUDENT_DISCOUNT%TYPE DEFAULT 0
) AS
BEGIN
  INSERT INTO CONFERENCES(CONFERENCE_NAME, COUNTRY, CITY, ADDRESS, FIRST_DAY, LAST_DAY, STUDENT_DISCOUNT)
    VALUES(i_conf_name, i_country, i_city, i_address, i_first_day, i_last_day, i_student_discount);
END;


CREATE OR REPLACE PROCEDURE ADD_CONFERENCE_DAY(
  i_conf_id IN CONFERENCE_DAYS.CONFERENCE_ID%TYPE,
  i_price IN CONFERENCE_DAYS.PRICE%TYPE,
  i_limit IN CONFERENCE_DAYS.LIMIT%TYPE,
  i_day_date IN CONFERENCE_DAYS.DAY_DATE%TYPE
) AS
BEGIN
  INSERT INTO CONFERENCE_DAYS(CONFERENCE_ID, PRICE, LIMIT, DAY_DATE)
    VALUES(i_conf_id, i_price, i_limit, i_day_date);
END;


CREATE OR REPLACE PROCEDURE ADD_WORKSHOPS(
  i_conf_day_id IN WORKSHOPS.CONF_DAY_ID%TYPE,
  i_workshop_name IN WORKSHOPS.WORKSHOP_NAME%TYPE,
  i_start_time IN WORKSHOPS.START_TIME%TYPE,
  i_end_time IN WORKSHOPS.END_TIME%TYPE,
  i_price IN WORKSHOPS.PRICE%TYPE,
  i_limit IN WORKSHOPS.LIMIT%TYPE
) AS
BEGIN
  INSERT INTO WORKSHOPS(CONF_DAY_ID, WORKSHOP_NAME, START_TIME, END_TIME, PRICE, LIMIT)
    VALUES(i_conf_day_id, i_workshop_name, i_start_time, i_end_time, i_price, i_limit);
END;


CREATE OR REPLACE PROCEDURE ADD_PRICE(
  i_conf_id IN PRICES.CONFERENCE_ID%TYPE,
  i_discount IN PRICES.DISCOUNT%TYPE,
  i_end_date IN PRICES.END_DATE%TYPE
) AS
BEGIN
  INSERT INTO PRICES(CONFERENCE_ID, DISCOUNT, END_DATE)
    VALUES(i_conf_id, i_discount, i_end_date);
END;


CREATE OR REPLACE PROCEDURE ADD_CLIENT(
  i_is_company IN CLIENTS.IS_COMPANY%TYPE DEFAULT 'N',
  i_client_name IN CLIENTS.CLIENT_NAME%TYPE,
  i_country IN CLIENTS.COUNTRY%TYPE DEFAULT NULL,
  i_city IN CLIENTS.CITY%TYPE DEFAULT NULL,
  i_address IN CLIENTS.ADDRESS%TYPE DEFAULT NULL,
  i_phone IN CLIENTS.PHONE%TYPE DEFAULT NULL,
  i_email IN CLIENTS.EMAIL%TYPE,
  i_password IN CLIENTS.PASSWORD%TYPE
) AS
BEGIN
  INSERT INTO CLIENTS(IS_COMPANY, CLIENT_NAME, COUNTRY, CITY, ADDRESS, PHONE, EMAIL, PASSWORD)
    VALUES(i_is_company, i_client_name, i_country, i_city, i_address, i_phone, i_email, i_password);
END;


CREATE OR REPLACE PROCEDURE UPDATE_CONFERENCE(
  i_conf_id IN CONFERENCES.CONFERENCE_ID%TYPE,
  i_conference_name IN CONFERENCES.CONFERENCE_NAME%TYPE DEFAULT NULL,
  i_country IN CONFERENCES.COUNTRY%TYPE DEFAULT NULL,
  i_city IN CONFERENCES.CITY%TYPE DEFAULT NULL,
  i_address IN CONFERENCES.ADDRESS%TYPE DEFAULT NULL,
  i_student_discount IN CONFERENCES.STUDENT_DISCOUNT%TYPE DEFAULT NULL
) AS
BEGIN
  IF NOT CHECK_CONFERENCE_EXISTS(i_conf_id) THEN
    RAISE_APPLICATION_ERROR(-20400, 'Wrong conference_id!');
  ELSE
    UPDATE CONFERENCES
      SET CONFERENCE_NAME = NVL(i_conference_name, CONFERENCE_NAME),
          COUNTRY = NVL(i_country, COUNTRY),
          CITY = NVL(i_city, CITY),
          ADDRESS = NVL(i_address, ADDRESS),
          STUDENT_DISCOUNT = NVL(i_student_discount, STUDENT_DISCOUNT)
    WHERE CONFERENCES.CONFERENCE_ID = i_conf_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE UPDATE_CONF_DAY(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE,
  i_price IN CONFERENCE_DAYS.PRICE%TYPE DEFAULT NULL,
  i_limit IN CONFERENCE_DAYS.LIMIT%TYPE DEFAULT NULL
) AS
BEGIN
  IF NOT CHECK_CONF_DAY_EXISTS(i_conf_day_id) THEN
    RAISE_APPLICATION_ERROR(-20401, 'Wrong conf_day_id!');
  ELSE
    UPDATE CONFERENCE_DAYS
      SET PRICE = NVL(i_price, PRICE),
          LIMIT = NVL(i_limit, LIMIT)
      WHERE CONFERENCE_DAYS.CONF_DAY_ID = i_conf_day_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE UPDATE_WORKSHOPS(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE,
  i_workshop_name IN WORKSHOPS.WORKSHOP_NAME%TYPE DEFAULT NULL,
  i_price IN WORKSHOPS.PRICE%TYPE DEFAULT NULL,
  i_limit IN WORKSHOPS.LIMIT%TYPE DEFAULT NULL
) AS
BEGIN
  IF NOT CHECK_WORKSHOP_EXISTS(i_workshop_id) THEN
    RAISE_APPLICATION_ERROR(-20402, 'Wrong workshop_id!');
  ELSE
    UPDATE WORKSHOPS
      SET WORKSHOP_NAME = NVL(i_workshop_name, WORKSHOP_NAME),
          PRICE = NVL(i_price, PRICE),
          LIMIT = NVL(i_limit, LIMIT)
      WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE DELETE_CONFERENCE(
  i_conf_id IN CONFERENCES.CONFERENCE_ID%TYPE
) AS
BEGIN
  IF NOT CHECK_CONFERENCE_EXISTS(i_conf_id) THEN
    RAISE_APPLICATION_ERROR(-20403, 'Wrong conf_id!');
  ELSE
    DELETE FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = i_conf_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE DELETE_CONF_DAY(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE
) AS
BEGIN
  IF NOT CHECK_CONF_DAY_EXISTS(i_conf_day_id) THEN
    RAISE_APPLICATION_ERROR(-20404, 'Wrong conf_day_id!');
  ELSE
    DELETE FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = i_conf_day_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE DELETE_WORKSHOP(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE
) AS
BEGIN
  IF CHECK_WORKSHOP_EXISTS(i_workshop_id) THEN
    RAISE_APPLICATION_ERROR(-20405, 'Wrong workshop_id!');
  ELSE
    DELETE FROM WORKSHOPS
    WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE DELETE_PRICE(
  i_price_id IN PRICES.PRICE_ID%TYPE
) AS
  l_price_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_price_count
    FROM PRICES
    WHERE PRICES.PRICE_ID = i_price_id;
  END;

  IF (l_price_count = 0) THEN
    RAISE_APPLICATION_ERROR(-20406, 'Wrong price_id!');
  ELSE
    DELETE FROM PRICES
    WHERE PRICES.PRICE_ID = i_price_id;
  END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_BOOKING(
  i_client_id IN CLIENTS.CLIENT_ID%TYPE,
  i_conf_id IN CONFERENCES.CONFERENCE_ID%TYPE
) AS
BEGIN
  INSERT INTO BOOKINGS(CLIENT_ID, CONFERENCE_ID, IS_CANCELLED, BOOKING_DATE)
    VALUES(i_client_id, i_conf_id, 'N', CURRENT_DATE);
END;


CREATE OR REPLACE PROCEDURE ADD_CONF_DAY_BOOKING(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE,
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE,
  i_num_attendees IN INTEGER,
  i_num_students IN INTEGER
) AS
  l_booking_cancelled CHAR;
  l_is_company CHAR;
  l_available_places_count INTEGER;
BEGIN
  BEGIN
    SELECT IS_CANCELLED INTO l_booking_cancelled
    FROM BOOKINGS
    WHERE BOOKINGS.BOOKING_ID = i_booking_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_booking_cancelled := NULL;
  END;

  IF (l_booking_cancelled = 'Y') THEN
    RAISE_APPLICATION_ERROR(-20407, 'Cannot add conference day booking to cancelled conference booking!');
  ELSE
    BEGIN
      SELECT C.IS_COMPANY INTO l_is_company
      FROM BOOKINGS B
        JOIN CLIENTS C ON B.CLIENT_ID = C.CLIENT_ID
      WHERE B.BOOKING_ID = i_booking_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_is_company := NULL;
    END;

    IF (l_is_company = 'N' AND i_num_attendees > 1) THEN
      RAISE_APPLICATION_ERROR(-20407, 'Non-institutional clients cannot book more than one place per conference day!');
    ELSE
      l_available_places_count := AVAILABLE_CONF_DAY_PLACES_COUNT(i_conf_day_id);
      IF (i_num_attendees > l_available_places_count) THEN
        RAISE_APPLICATION_ERROR(-20407, 'Too many attendees!');
      ELSE
      INSERT INTO CONF_DAY_BOOKINGS(BOOKING_ID, CONF_DAY_ID, NUMBER_OF_ATTENDEES, NUMBER_OF_STUDENTS,
                                    IS_CANCELLED)
        VALUES (i_booking_id, i_conf_day_id, i_num_attendees, i_num_students, 'N');
      END IF;
    END IF;
  END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_WORKSHOP_BOOKING(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE,
  i_conf_day_booking_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE,
  i_num_attendees IN INTEGER,
  i_num_students IN INTEGER
) AS
  l_is_cancelled CHAR;
  l_booked_conf_day_places_count INTEGER;
  l_available_places_count INTEGER;
BEGIN
  BEGIN
    SELECT IS_CANCELLED INTO l_is_cancelled
    FROM CONF_DAY_BOOKINGS
    WHERE CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID = i_conf_day_booking_id;
  END;

  IF (l_is_cancelled = 'Y') THEN
    RAISE_APPLICATION_ERROR(-20408, 'Cannot add workshop booking to cancelled conference day booking!');
  ELSE
    BEGIN
      SELECT NUMBER_OF_ATTENDEES INTO l_booked_conf_day_places_count
      FROM CONF_DAY_BOOKINGS
      WHERE CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID = i_conf_day_booking_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_booked_conf_day_places_count := NULL;
    END;

    IF (l_booked_conf_day_places_count < i_num_attendees) THEN
      RAISE_APPLICATION_ERROR(-20408, 'Number of attendees for workshop exceeds number of attendees for ' ||
                                      'conference day!');
    ELSE
      BEGIN
        SELECT NUMBER_OF_STUDENTS INTO l_booked_conf_day_places_count
        FROM CONF_DAY_BOOKINGS
        WHERE CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID = i_conf_day_booking_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_booked_conf_day_places_count := NULL;
      END;

      IF (l_booked_conf_day_places_count < i_num_students) THEN
        RAISE_APPLICATION_ERROR(-20408, 'Number of students for workshop exceeds number of students for ' ||
                                        'conference day!');
      ELSE
        l_available_places_count := AVAILABLE_WORKSHOP_PLACES_COUNT(i_workshop_id);
        IF (i_num_attendees > l_available_places_count) THEN
          RAISE_APPLICATION_ERROR(-20408, 'Too many attendees!');
        ELSE
          INSERT INTO WORKSHOP_BOOKINGS(CONF_DAY_BOOKING_ID, WORKSHOP_ID, NUMBER_OF_ATTENDEES, NUMBER_OF_STUDENTS,
                                        IS_CANCELLED)
            VALUES(i_conf_day_booking_id, i_workshop_id, i_num_attendees, i_num_students, 'N');
        END IF;
      END IF;
    END IF;
  END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_ATTENDEE(
  i_first_name IN ATTENDEES.FIRST_NAME%TYPE,
  i_last_name IN ATTENDEES.LAST_NAME%TYPE,
  i_student_card IN ATTENDEES.STUDENT_CARD%TYPE DEFAULT NULL,
  i_email IN ATTENDEES.EMAIL%TYPE,
  i_phone IN ATTENDEES.PHONE%TYPE DEFAULT NULL
) AS
BEGIN
  INSERT INTO ATTENDEES(FIRST_NAME, LAST_NAME, STUDENT_CARD, EMAIL, PHONE)
    VALUES(i_first_name, i_last_name, i_student_card, i_email, i_phone);
END;


CREATE OR REPLACE PROCEDURE ADD_CONF_DAY_PARTICIPATION(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE,
  i_attendee_id IN ATTENDEES.ATTENDEE_ID%TYPE,
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE,
  i_is_student IN CHAR DEFAULT 'N'
) AS
  -- Has conference day booking been cancelled?
  l_booking_cancelled CONF_DAY_BOOKINGS.IS_CANCELLED%TYPE;
  -- ID of conference day booking.
  l_conf_day_booking_id CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID%TYPE;
  -- Number of attendees already signed up for conference day.
  l_conf_day_participants_count INTEGER;
  -- Number of places booked for this conference day.
  l_booked_conf_day_places_count INTEGER;
BEGIN
  -- Find ID of conference day booking and whether it is cancelled or not.
  BEGIN
    SELECT IS_CANCELLED, CONF_DAY_BOOKING_ID INTO l_booking_cancelled, l_conf_day_booking_id
    FROM CONF_DAY_BOOKINGS CDB
    WHERE CDB.BOOKING_ID = i_booking_id
          AND CDB.CONF_DAY_ID = i_conf_day_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20409, 'Conference day booking does not exist!');
  END;

  -- Check if conference day booking was not cancelled.
  IF (l_booking_cancelled = 'Y') THEN
    RAISE_APPLICATION_ERROR(-20409, 'Cannot add participants to cancelled conference day booking!');
  ELSE
    -- Get number of already signed up participants (students/non-students).
    l_conf_day_participants_count := CONF_DAY_PARTICIPANTS_COUNT(i_conf_day_id, i_booking_id, i_is_student);

    -- Get booked number of participants.
    BEGIN
      SELECT
        CASE i_is_student
          WHEN 'Y' THEN NUMBER_OF_STUDENTS
          WHEN 'N' THEN NUMBER_OF_ATTENDEES - NUMBER_OF_STUDENTS
          ELSE NULL
          END
      INTO l_booked_conf_day_places_count
      FROM CONF_DAY_BOOKINGS CDB
      WHERE CDB.CONF_DAY_BOOKING_ID = l_conf_day_booking_id;
    END;

    IF (l_booked_conf_day_places_count <= l_conf_day_participants_count) THEN
      RAISE_APPLICATION_ERROR(-20409, 'All places booked for this conference day already have ' ||
                                      'an attendee assigned!');
    ELSE
      INSERT INTO PARTICIPATION_CONF_DAYS(CONF_DAY_ID, ATTENDEE_ID, BOOKING_ID, IS_STUDENT)
        VALUES(i_conf_day_id, i_attendee_id, i_booking_id, i_is_student);
    END IF;
  END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_WORKSHOP_PARTICIPATION(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE,
  i_participation_conf_day_id IN PARTICIPATION_CONF_DAYS.PARTICIPATION_CONF_DAY_ID%TYPE
) AS
  -- ID of attendee.
  l_attendee_id ATTENDEES.ATTENDEE_ID%TYPE;
  -- Has workshop booking been cancelled?
  l_booking_cancelled WORKSHOP_BOOKINGS.IS_CANCELLED%TYPE;
  -- ID of the whole booking.
  l_booking_id BOOKINGS.BOOKING_ID%TYPE;
  -- ID of conference day.
  l_conf_day_id CONFERENCE_DAYS.CONF_DAY_ID%TYPE;
  -- Number of attendees already signed up for this workshop.
  l_workshop_participants_count INTEGER;
  -- Number of places booked for this workshop.
  l_booked_workshop_places_count INTEGER;
  -- Is this a student reservation?
  l_is_student PARTICIPATION_CONF_DAYS.IS_STUDENT%TYPE;
BEGIN
  /*
   * -> Conference and conference day bookings are not cancelled if participation in conference day exists.
   *    No need to check.
   * -> Gotta check if workshop booking is not cancelled.
   * -> Gotta check if there are places left for this workshop.
   * -> Gotta check if this attendee is not signed up already for overlapping workshop on the same day.
   */
  BEGIN
    SELECT IS_STUDENT INTO l_is_student
    FROM PARTICIPATION_CONF_DAYS PCD
    WHERE PCD.PARTICIPATION_CONF_DAY_ID = i_participation_conf_day_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20410, 'No such participation found for this conference day!');
  END;

  BEGIN
    SELECT PCD.ATTENDEE_ID,
           PCD.BOOKING_ID,
           PCD.CONF_DAY_ID,
           WB.IS_CANCELLED,
           CASE l_is_student
             WHEN 'Y' THEN WB.NUMBER_OF_STUDENTS
             WHEN 'N' THEN WB.NUMBER_OF_ATTENDEES - WB.NUMBER_OF_STUDENTS
             END
    INTO l_attendee_id,
         l_booking_id,
         l_conf_day_id,
         l_booking_cancelled,
         l_booked_workshop_places_count
    FROM PARTICIPATION_CONF_DAYS PCD
      JOIN CONF_DAY_BOOKINGS CDB ON PCD.BOOKING_ID = CDB.BOOKING_ID
                                    AND PCD.CONF_DAY_ID = CDB.CONF_DAY_ID
      JOIN WORKSHOP_BOOKINGS WB ON CDB.CONF_DAY_BOOKING_ID = WB.CONF_DAY_BOOKING_ID
    WHERE PCD.PARTICIPATION_CONF_DAY_ID = i_participation_conf_day_id
          AND WB.WORKSHOP_ID = i_workshop_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20410, 'Workshop booking does not exist!');
  END;

  IF (l_booking_cancelled = 'Y') THEN
    RAISE_APPLICATION_ERROR(-20410, 'Cannot add participants to cancelled workshop booking!');
  ELSE
    l_workshop_participants_count := WORKSHOP_PARTICIPANTS_COUNT(i_workshop_id, l_booking_id, l_is_student);

    IF (l_booked_workshop_places_count <= l_workshop_participants_count) THEN
      RAISE_APPLICATION_ERROR(-20410, 'All places booked for this workshop already have ' ||
                                      'an attendee assigned!');
    ELSE
      DECLARE
        CURSOR c_workshops_cursor IS (SELECT PW.WORKSHOP_ID
                                      FROM PARTICIPATION_CONF_DAYS PCD
                                        JOIN PARTICIPATION_WORKSHOPS PW
                                          ON PCD.PARTICIPATION_CONF_DAY_ID = PW.PARTICIPATION_CONF_DAY_ID
                                      WHERE PCD.ATTENDEE_ID = l_attendee_id
                                            AND PCD.CONF_DAY_ID = l_conf_day_id);
        l_workshop_overlap BOOLEAN := FALSE;
        l_workshop_id WORKSHOPS.WORKSHOP_ID%TYPE;
      BEGIN
        OPEN c_workshops_cursor;
        LOOP
          FETCH c_workshops_cursor INTO l_workshop_id;
          EXIT WHEN c_workshops_cursor%NOTFOUND OR l_workshop_overlap;
          l_workshop_overlap := WORKSHOPS_OVERLAP(l_workshop_id, i_workshop_id);
        END LOOP;
        CLOSE c_workshops_cursor;

        IF l_workshop_overlap THEN
          RAISE_APPLICATION_ERROR(-20410, 'Attendee is already signed up for overlapping workshops!');
        ELSE
          INSERT INTO PARTICIPATION_WORKSHOPS(WORKSHOP_ID, PARTICIPATION_CONF_DAY_ID)
            VALUES (i_workshop_id, i_participation_conf_day_id);
        END IF;
      END;
    END IF;
  END IF;
END;


CREATE OR REPLACE PROCEDURE ADD_PAYMENT(
  i_booking_id IN PAYMENTS.BOOKING_ID%TYPE,
  i_payment_date IN PAYMENTS.PAYMENT_DATE%TYPE,
  i_value IN PAYMENTS.VALUE%TYPE,
  i_means IN PAYMENTS.MEANS%TYPE
) AS
BEGIN
  INSERT INTO PAYMENTS(BOOKING_ID, PAYMENT_DATE, VALUE, MEANS)
    VALUES(i_booking_id, i_payment_date, i_value, i_means);
END;


CREATE OR REPLACE PROCEDURE CANCEL_WORKSHOP_BOOKING(
  i_workshop_booking_id IN WORKSHOP_BOOKINGS.WORKSHOP_BOOKING_ID%TYPE
) AS
BEGIN
  BEGIN
    UPDATE WORKSHOP_BOOKINGS
      SET IS_CANCELLED = 'Y'
      WHERE WORKSHOP_BOOKINGS.WORKSHOP_BOOKING_ID = i_workshop_booking_id;
  END;

  BEGIN
    DELETE FROM PARTICIPATION_WORKSHOPS
    WHERE PARTICIPATION_WORKSHOP_ID IN
          (SELECT PW.PARTICIPATION_WORKSHOP_ID
           FROM WORKSHOP_BOOKINGS WB
             JOIN CONF_DAY_BOOKINGS CDB ON WB.CONF_DAY_BOOKING_ID = CDB.CONF_DAY_BOOKING_ID
             JOIN PARTICIPATION_CONF_DAYS PCD ON CDB.BOOKING_ID = PCD.BOOKING_ID
             JOIN PARTICIPATION_WORKSHOPS PW ON PCD.PARTICIPATION_CONF_DAY_ID = PW.PARTICIPATION_CONF_DAY_ID
           WHERE WB.WORKSHOP_BOOKING_ID = i_workshop_booking_id
                 AND PW.WORKSHOP_ID = WB.WORKSHOP_ID);
  END;
END;


CREATE OR REPLACE PROCEDURE CANCEL_CONF_DAY_BOOKING(
  i_conf_day_booking_id IN CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID%TYPE
) AS
BEGIN
  -- Cancel all corresponding workshop bookings first.
  DECLARE
    CURSOR c_workshop_bookings_cursor IS (SELECT WB.WORKSHOP_BOOKING_ID
                                          FROM WORKSHOP_BOOKINGS WB
                                          WHERE WB.CONF_DAY_BOOKING_ID = i_conf_day_booking_id);
    l_workshop_booking_id WORKSHOP_BOOKINGS.WORKSHOP_BOOKING_ID%TYPE;
  BEGIN
    OPEN c_workshop_bookings_cursor;
    LOOP
      FETCH c_workshop_bookings_cursor INTO l_workshop_booking_id;
      EXIT WHEN c_workshop_bookings_cursor%NOTFOUND;
      CANCEL_WORKSHOP_BOOKING(l_workshop_booking_id);
    END LOOP;
    CLOSE c_workshop_bookings_cursor;
  END;

  -- Cancel conference day booking itself.
  BEGIN
    UPDATE CONF_DAY_BOOKINGS
      SET IS_CANCELLED = 'Y'
      WHERE CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID = i_conf_day_booking_id;
  END;

  DELETE FROM PARTICIPATION_CONF_DAYS PCD
  WHERE PCD.PARTICIPATION_CONF_DAY_ID IN
        (SELECT PCD2.PARTICIPATION_CONF_DAY_ID
         FROM CONF_DAY_BOOKINGS CDB
           JOIN PARTICIPATION_CONF_DAYS PCD2
             ON PCD2.BOOKING_ID = CDB.BOOKING_ID
                AND PCD2.CONF_DAY_ID = CDB.CONF_DAY_ID
         WHERE CDB.CONF_DAY_BOOKING_ID = i_conf_day_booking_id);
END;


CREATE OR REPLACE PROCEDURE CANCEL_BOOKING(
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE
) AS
  CURSOR c_conf_days_cursor IS (SELECT CONF_DAY_BOOKING_ID
                                FROM CONF_DAY_BOOKINGS CDB
                                WHERE CDB.BOOKING_ID = i_booking_id);
  l_conf_day_booking_id CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID%TYPE;
BEGIN
  -- Cancel all corresponding conference day bookings first.
  OPEN c_conf_days_cursor;
  LOOP
    FETCH c_conf_days_cursor INTO l_conf_day_booking_id;
    EXIT WHEN c_conf_days_cursor%NOTFOUND;
    CANCEL_CONF_DAY_BOOKING(l_conf_day_booking_id);
  END LOOP;
  CLOSE c_conf_days_cursor;

  -- Cancel the whole booking.
  UPDATE BOOKINGS
    SET IS_CANCELLED = 'Y'
    WHERE BOOKINGS.BOOKING_ID = i_booking_id;
END;


CREATE OR REPLACE PROCEDURE CHANGE_CONF_DAY_BOOKING_PLACES(
  i_conf_day_booking_id IN CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID%TYPE,
  i_num_attendees IN CONF_DAY_BOOKINGS.NUMBER_OF_ATTENDEES%TYPE,
  i_num_students IN CONF_DAY_BOOKINGS.NUMBER_OF_STUDENTS%TYPE
) AS
BEGIN
  /*
   * -> Gotta check if there is enough free places on the day to add more.
   * -> Gotta check if there is enough unassigned places to shrink.
   * -> Gotta check if workshop places count remains valid.
   * Mmm.. Add a trigger to handle workshop booking places vs conference day booking places??
   * Well, no idea. I guess we might wanna have complex logic in one place, not two.
   */

END;


/*
*
* FUNCTIONS
*
*/


CREATE OR REPLACE FUNCTION CHECK_CONFERENCE_EXISTS(
  i_conf_id IN CONFERENCES.CONFERENCE_ID%TYPE
) RETURN BOOLEAN AS
  l_conf_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_conf_count
    FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = i_conf_id;
  END;

  RETURN (l_conf_count > 0);
END;


CREATE OR REPLACE FUNCTION CHECK_CONF_DAY_EXISTS(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE
) RETURN BOOLEAN AS
  l_conf_day_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_conf_day_count
      FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = i_conf_day_id;
  END;

  RETURN (l_conf_day_count > 0);
END;


CREATE OR REPLACE FUNCTION CHECK_WORKSHOP_EXISTS(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE
) RETURN BOOLEAN AS
  l_workshop_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_workshop_count
    FROM WORKSHOPS
    WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id;
  END;

  RETURN (l_workshop_count > 0);
END;


CREATE OR REPLACE FUNCTION AVAILABLE_CONF_DAY_PLACES_COUNT(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE
) RETURN INTEGER AS
  l_taken INTEGER := 0;
  l_total CONFERENCE_DAYS.LIMIT%TYPE;
BEGIN
  BEGIN
    SELECT LIMIT INTO l_total
    FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = i_conf_day_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20500, 'Incorrect conf_day_id provided!');
  END;

  BEGIN
    SELECT SUM(NUMBER_OF_ATTENDEES) INTO l_taken
    FROM CONF_DAY_BOOKINGS
    WHERE CONF_DAY_BOOKINGS.CONF_DAY_ID = i_conf_day_id
          AND IS_CANCELLED = 'N';
  END;

  l_total := l_total - l_taken;
  RETURN l_total;
END;


CREATE OR REPLACE FUNCTION AVAILABLE_WORKSHOP_PLACES_COUNT(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE
) RETURN INTEGER AS
  l_taken INTEGER := 0;
  l_total WORKSHOPS.LIMIT%TYPE;
BEGIN
  BEGIN
    SELECT LIMIT INTO l_total
    FROM WORKSHOPS
    WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20501, 'Incorrect workshop_id provided!');
  END;

  BEGIN
    SELECT SUM(NUMBER_OF_ATTENDEES) INTO l_taken
    FROM WORKSHOP_BOOKINGS
    WHERE WORKSHOP_BOOKINGS.WORKSHOP_ID = i_workshop_id
          AND IS_CANCELLED = 'N';
  END;

  l_total := l_total - l_taken;
  RETURN l_total;
END;


CREATE OR REPLACE FUNCTION WORKSHOPS_OVERLAP(
  i_workshop_id1 IN WORKSHOPS.WORKSHOP_ID%TYPE,
  i_workshop_id2 IN WORKSHOPS.WORKSHOP_ID%TYPE
) RETURN BOOLEAN AS
  l_start1 WORKSHOPS.START_TIME%TYPE;
  l_end1 WORKSHOPS.END_TIME%TYPE;
  l_start2 WORKSHOPS.START_TIME%TYPE;
  l_end2 WORKSHOPS.END_TIME%TYPE;
BEGIN
  BEGIN
    SELECT START_TIME, END_TIME INTO l_start1, l_end1
    FROM WORKSHOPS
    WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id1;
    SELECT START_TIME, END_TIME INTO l_start2, l_end2
    FROM WORKSHOPS
    WHERE WORKSHOPS.WORKSHOP_ID = i_workshop_id2;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20502, 'Incorrect workshop_id provided!');
  END;

  IF (l_end1 <= l_start2 OR l_end2 <= l_start1) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END;


CREATE OR REPLACE FUNCTION CAN_DELETE_CONF_DAY(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE
) RETURN BOOLEAN AS
  l_total CONFERENCE_DAYS.LIMIT%TYPE;
  l_available INTEGER := AVAILABLE_CONF_DAY_PLACES_COUNT(i_conf_day_id);
BEGIN
  BEGIN
    SELECT LIMIT INTO l_total
    FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = i_conf_day_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20503, 'Incorrect conf_day_id provided!');
  END;

  IF (l_available < l_total) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;
END;


CREATE OR REPLACE FUNCTION BOOKING_VALUE(
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE
) RETURN NUMBER AS
  l_conference_id CONFERENCES.CONFERENCE_ID%TYPE;
  l_booking_date BOOKINGS.BOOKING_DATE%TYPE;
  l_student_discount NUMBER;
  l_advance_discount NUMBER;
  l_conf_days_value NUMBER;
  l_total_value NUMBER;
BEGIN
  BEGIN
    SELECT CONFERENCE_ID, BOOKING_DATE INTO l_conference_id, l_booking_date
    FROM BOOKINGS
    WHERE BOOKING_ID = i_booking_id;

    SELECT STUDENT_DISCOUNT INTO l_student_discount
    FROM CONFERENCES C
    WHERE C.CONFERENCE_ID = l_conference_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20504, 'Incorrect booking_id!');
  END;

  BEGIN
    SELECT DISCOUNT INTO l_advance_discount
    FROM PRICES
    WHERE PRICES.CONFERENCE_ID = l_conference_id
          AND PRICES.END_DATE > l_booking_date
    ORDER BY PRICES.END_DATE
    FETCH FIRST 1 ROWS ONLY;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_advance_discount := 0;
  END;

  BEGIN
    SELECT COALESCE(SUM(CDB.NUMBER_OF_STUDENTS * CD.PRICE) * (100 - l_student_discount)
           + SUM((CDB.NUMBER_OF_ATTENDEES - CDB.NUMBER_OF_STUDENTS) * CD.PRICE), 0) * l_advance_discount
    INTO l_conf_days_value
    FROM CONF_DAY_BOOKINGS CDB
      JOIN CONFERENCE_DAYS CD ON CDB.CONF_DAY_ID = CD.CONF_DAY_ID
    WHERE CDB.BOOKING_ID = i_booking_id;

    SELECT COALESCE(SUM(WB.NUMBER_OF_STUDENTS * W.PRICE) * (100 - l_student_discount)
           + SUM((WB.NUMBER_OF_ATTENDEES - WB.NUMBER_OF_STUDENTS) * W.PRICE), 0)
    INTO l_total_value
    FROM CONF_DAY_BOOKINGS CDB
      JOIN WORKSHOP_BOOKINGS WB ON CDB.CONF_DAY_BOOKING_ID = WB.CONF_DAY_BOOKING_ID
      JOIN WORKSHOPS W ON WB.WORKSHOP_ID = W.WORKSHOP_ID
    WHERE CDB.BOOKING_ID = i_booking_id;
  END;

  l_total_value := l_total_value + l_conf_days_value;
  RETURN l_total_value;
END;


CREATE OR REPLACE FUNCTION CONF_DAY_PARTICIPANTS_COUNT(
  i_conf_day_id IN CONFERENCE_DAYS.CONF_DAY_ID%TYPE,
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE,
  -- Count only students vs count only normal attendees.
  i_student IN PARTICIPATION_CONF_DAYS.IS_STUDENT%TYPE
) RETURN INTEGER AS
  l_participants_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_participants_count
    FROM PARTICIPATION_CONF_DAYS PCD
    WHERE PCD.BOOKING_ID = i_booking_id
          AND PCD.CONF_DAY_ID = i_conf_day_id
          AND PCD.IS_STUDENT = i_student;
  END;

  RETURN l_participants_count;
END;


CREATE OR REPLACE FUNCTION WORKSHOP_PARTICIPANTS_COUNT(
  i_workshop_id IN WORKSHOPS.WORKSHOP_ID%TYPE,
  i_booking_id IN BOOKINGS.BOOKING_ID%TYPE,
  -- Count only students vs count only normal attendees.
  i_student IN PARTICIPATION_CONF_DAYS.IS_STUDENT%TYPE
) RETURN INTEGER AS
  l_participants_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_participants_count
    FROM PARTICIPATION_CONF_DAYS PCD
      JOIN PARTICIPATION_WORKSHOPS PW ON
        PCD.PARTICIPATION_CONF_DAY_ID = PW.PARTICIPATION_CONF_DAY_ID
    WHERE PCD.BOOKING_ID = i_booking_id
          AND PW.WORKSHOP_ID = i_workshop_id
          AND PCD.IS_STUDENT = i_student;
  END;

  RETURN l_participants_count;
END;


CREATE OR REPLACE FUNCTION CONFERENCE_PLACES_BOOKED_AVG(
  i_client_id IN CLIENTS.CLIENT_ID%TYPE
) RETURN INTEGER AS
  l_places_avg NUMBER;
BEGIN
  BEGIN
    SELECT AVG(PLACES_BOOKED) INTO l_places_avg
    FROM (SELECT SUM(NUMBER_OF_ATTENDEES) AS PLACES_BOOKED
          FROM BOOKINGS B
            JOIN CONF_DAY_BOOKINGS CDB ON B.BOOKING_ID = CDB.BOOKING_ID
                                          AND CDB.IS_CANCELLED = 'N'
          WHERE B.CLIENT_ID = i_client_id
          GROUP BY B.BOOKING_ID);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20505, 'Incorrect client_id!');
  END;

  RETURN ROUND(l_places_avg);
END;

CREATE OR REPLACE FUNCTION CHECK_CLIENT_EXISTS(
  i_client_ID IN CLIENTS.CLIENT_ID%TYPE
)
  RETURN BOOLEAN AS
  l_client_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_client_count
    FROM CLIENTS
    WHERE CLIENTS.CLIENT_ID = i_client_ID;
  END;
  RETURN (l_client_count > 0);
END;

CREATE OR REPLACE FUNCTION WORKSHOP_PLACES_BOOKED_AVG(
  i_client_id IN CLIENTS.CLIENT_ID%TYPE
) RETURN INTEGER AS
  l_places_avg NUMBER;
BEGIN
  BEGIN
    SELECT AVG(PLACES_BOOKED) INTO l_places_avg
    FROM (SELECT SUM(WB.NUMBER_OF_ATTENDEES) AS PLACES_BOOKED
          FROM BOOKINGS B
            JOIN CONF_DAY_BOOKINGS CDB ON B.BOOKING_ID = CDB.BOOKING_ID
            JOIN WORKSHOP_BOOKINGS WB ON CDB.CONF_DAY_BOOKING_ID = WB.CONF_DAY_BOOKING_ID
                                         AND WB.IS_CANCELLED = 'N'
          WHERE B.CLIENT_ID = i_client_id
          GROUP BY B.BOOKING_ID);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20505, 'Incorrect client_id!');
  END;

  RETURN ROUND(l_places_avg);
END;
-- CREATE OR REPLACE PACKAGE ...? AS ...!
-- TODO: PROCEDURE_NAME_P??
