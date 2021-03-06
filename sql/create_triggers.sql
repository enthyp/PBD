CREATE OR REPLACE TRIGGER CONF_DAY_DURING_CONFERENCE_TRG
  BEFORE INSERT OR UPDATE OF DAY_DATE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  l_day_date CONFERENCE_DAYS.DAY_DATE%TYPE;
  l_conf_first_day CONFERENCES.FIRST_DAY%TYPE;
  l_conf_last_day CONFERENCES.LAST_DAY%TYPE;
BEGIN
  l_day_date := :new.DAY_DATE;

  BEGIN
    SELECT FIRST_DAY, LAST_DAY INTO l_conf_first_day, l_conf_last_day
    FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_conf_first_day := NULL;
      l_conf_last_day := NULL;
  END;

  IF NOT (l_day_date BETWEEN l_conf_first_day AND l_conf_last_day) THEN
    RAISE_APPLICATION_ERROR(-20000, 'The date of conference day must match the conference ' ||
                                    'start and end dates!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_LIMIT_LEQ_DAY_LIMIT_TRG
  BEFORE INSERT OR UPDATE OF LIMIT ON WORKSHOPS
  FOR EACH ROW
DECLARE
  l_day_limit INTEGER;
  l_workshops_limit INTEGER;
BEGIN
  l_workshops_limit := :new.LIMIT;

  BEGIN
    SELECT LIMIT INTO l_day_limit
    FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = :new.CONF_DAY_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_day_limit := NULL;
  END;

  IF (l_day_limit < l_workshops_limit) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Workshop''s people limit cannot exceed conference day''s ' ||
                                    'people limit!');
  END IF;
END;


CREATE OR REPLACE TRIGGER PRICE_VALID_DATE_TRG
  BEFORE INSERT OR UPDATE OF END_DATE ON PRICES
  FOR EACH ROW
DECLARE
  l_thresh_end_date PRICES.END_DATE%TYPE;
  l_conf_start_date CONFERENCES.FIRST_DAY%TYPE;
BEGIN
  -- Check if threshold ends before the start of the conference.
  BEGIN
    SELECT FIRST_DAY INTO l_conf_start_date
    FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_conf_start_date := NULL;
  END;

  IF (l_thresh_end_date > l_conf_start_date) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Price threshold cannot span after the start of the conference!');
  END IF;
END;
--!

CREATE OR REPLACE TRIGGER PAYMENT_AFTER_BOOKING_TRG
  BEFORE INSERT OR UPDATE OF PAYMENT_DATE ON PAYMENTS
  FOR EACH ROW
DECLARE
  l_booking_date BOOKINGS.BOOKING_DATE%TYPE;
BEGIN
  BEGIN
    SELECT BOOKING_DATE INTO l_booking_date
    FROM BOOKINGS
    WHERE BOOKINGS.BOOKING_ID = :new.BOOKING_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_booking_date := NULL;
  END;

  IF (:new.PAYMENT_DATE < l_booking_date) THEN
    RAISE_APPLICATION_ERROR(-20004, 'Booking date must precede payment date!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_CONF_DAY_DATE_MATCH_TRG
  BEFORE INSERT OR UPDATE OF START_TIME, END_TIME ON WORKSHOPS
  FOR EACH ROW
DECLARE
  l_day_date CONFERENCE_DAYS.DAY_DATE%TYPE;
  l_start_time WORKSHOPS.START_TIME%TYPE;
  l_end_time WORKSHOPS.END_TIME%TYPE;
BEGIN
  l_start_time := :new.START_TIME;
  l_end_time := :new.END_TIME;

  BEGIN
    SELECT DAY_DATE INTO l_day_date
    FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = :new.CONF_DAY_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_day_date := NULL;
  END;

  IF (TRUNC(l_day_date) <> TRUNC(l_start_time) OR TRUNC(l_day_date) <> TRUNC(l_end_time)) THEN
    RAISE_APPLICATION_ERROR(-20006, 'Workshop date does not match date of the conference day!');
  END IF;
END;


CREATE OR REPLACE TRIGGER DISCOUNT_CHANGE_CHECK_PAYMENTS_TRG
  BEFORE UPDATE OF STUDENT_DISCOUNT ON CONFERENCES
  FOR EACH ROW
DECLARE
  l_payment_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_payment_count
    FROM PAYMENTS P
      JOIN BOOKINGS B ON B.BOOKING_ID = P.BOOKING_ID
      JOIN CONFERENCES C ON C.CONFERENCE_ID = B.CONFERENCE_ID
    WHERE C.CONFERENCE_ID = :new.CONFERENCE_ID;
  END;

  IF (l_payment_count > 0) THEN
    RAISE_APPLICATION_ERROR(-20007, 'Payment has already been made for previous discount value!');
  END IF;
END;


CREATE OR REPLACE TRIGGER CONF_DAY_PRICE_CHANGE_CHECK_PAYMENTS_TRG
  BEFORE UPDATE OF PRICE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  l_payment_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_payment_count
    FROM PAYMENTS P
      JOIN BOOKINGS B ON B.BOOKING_ID = P.BOOKING_ID
      JOIN CONF_DAY_BOOKINGS CDB on B.BOOKING_ID = CDB.BOOKING_ID
    WHERE CDB.CONF_DAY_ID = :new.CONF_DAY_ID;
  END;

  IF (l_payment_count > 0) THEN
    RAISE_APPLICATION_ERROR(-20008, 'Payment has already been made for previous price value!');
  END IF;
END;


CREATE OR REPLACE TRIGGER CONF_DAY_LIMIT_CHANGE_CHECK_BOOKINGS_TRG
  BEFORE UPDATE OF LIMIT ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  l_place_diff CONFERENCE_DAYS.LIMIT%TYPE := :old.LIMIT - :new.LIMIT;
  l_available_places_count INTEGER := AVAILABLE_CONF_DAY_PLACES_COUNT(:new.CONF_DAY_ID);
BEGIN
  IF (l_place_diff > l_available_places_count) THEN
    RAISE_APPLICATION_ERROR(-20009, 'Too many bookings to shrink limit!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_PRICE_CHANGE_CHECK_PAYMENTS_TRG
  BEFORE UPDATE OF PRICE ON WORKSHOPS
  FOR EACH ROW
DECLARE
  l_payment_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_payment_count
    FROM PAYMENTS P
      JOIN BOOKINGS B ON B.BOOKING_ID = P.BOOKING_ID
      JOIN CONF_DAY_BOOKINGS CDB on B.BOOKING_ID = CDB.BOOKING_ID
      JOIN WORKSHOP_BOOKINGS WB on CDB.CONF_DAY_BOOKING_ID = WB.CONF_DAY_BOOKING_ID
    WHERE WB.WORKSHOP_ID = :new.WORKSHOP_ID;
  END;

  IF (l_payment_count > 0) THEN
    RAISE_APPLICATION_ERROR(-20010, 'Payment has already been made for previous price value!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_LIMIT_CHANGE_CHECK_BOOKINGS_TRG
  BEFORE UPDATE OF LIMIT ON WORKSHOPS
  FOR EACH ROW
DECLARE
  l_place_diff WORKSHOPS.LIMIT%TYPE := :old.LIMIT - :new.LIMIT;
  l_available_places_count INTEGER := AVAILABLE_WORKSHOP_PLACES_COUNT(:new.WORKSHOP_ID);
BEGIN
  IF (l_place_diff > l_available_places_count) THEN
    RAISE_APPLICATION_ERROR(-20011, 'Too many bookings to shrink limit!');
  END IF;
END;


CREATE OR REPLACE TRIGGER CONFERENCE_DELETE_TRG
  BEFORE DELETE ON CONFERENCES
  FOR EACH ROW
DECLARE
  l_can_delete BOOLEAN := TRUE;
  i_conf_day_id CONFERENCE_DAYS.CONF_DAY_ID%TYPE;
  CURSOR c_conf_day_cursor IS (SELECT CONF_DAY_ID
                               FROM CONFERENCE_DAYS CD
                               WHERE CD.CONFERENCE_ID = :old.CONFERENCE_ID);
BEGIN
  OPEN c_conf_day_cursor;
  LOOP
    FETCH c_conf_day_cursor INTO i_conf_day_id;
    EXIT WHEN c_conf_day_cursor%NOTFOUND OR NOT l_can_delete;
    IF NOT CAN_DELETE_CONF_DAY(i_conf_day_id) THEN
      l_can_delete := FALSE;
    END IF;
  END LOOP;
  CLOSE c_conf_day_cursor;

  IF NOT l_can_delete THEN
    RAISE_APPLICATION_ERROR(-20012, 'Cannot delete already booked conference!');
  END IF;
END;


CREATE OR REPLACE TRIGGER CONF_DAY_DELETE_CHECK_BOOKINGS_TRG
  BEFORE DELETE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  l_total CONFERENCE_DAYS.LIMIT%TYPE := :old.LIMIT;
  l_available INTEGER := AVAILABLE_CONF_DAY_PLACES_COUNT(:old.CONF_DAY_ID);
BEGIN
  IF (l_available < l_total) THEN
    RAISE_APPLICATION_ERROR(-20013, 'Cannot delete already booked conference day!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_DELETE_CHECK_BOOKINGS_TRG
  BEFORE DELETE ON WORKSHOPS
  FOR EACH ROW
DECLARE
  l_total WORKSHOPS.LIMIT%TYPE := :old.LIMIT;
  l_available INTEGER := AVAILABLE_WORKSHOP_PLACES_COUNT(:old.WORKSHOP_ID);
BEGIN
  IF (l_available < l_total) THEN
    RAISE_APPLICATION_ERROR(-20014, 'Cannot delete already booked workshop!');
  END IF;
END;


CREATE OR REPLACE TRIGGER BOOKING_ADD_CHECK_DUPLICATES_TRG
  BEFORE INSERT OR UPDATE ON BOOKINGS
  FOR EACH ROW
DECLARE
  l_booking_count INTEGER;
BEGIN
  IF :new.IS_CANCELLED = 'N' THEN
    BEGIN
      SELECT COUNT(*) INTO l_booking_count
      FROM BOOKINGS
      WHERE BOOKINGS.BOOKING_ID <> :new.BOOKING_ID
            AND BOOKINGS.CLIENT_ID = :new.CLIENT_ID
            AND BOOKINGS.CONFERENCE_ID = :new.CONFERENCE_ID
            AND BOOKINGS.IS_CANCELLED = 'N';
    END;

    IF (l_booking_count > 0) THEN
      RAISE_APPLICATION_ERROR(-20015, 'Uncancelled identical booking already present!');
    END IF;
  END IF;
END;


CREATE OR REPLACE TRIGGER BOOKING_BEFORE_CONFERENCE_TRG
  BEFORE INSERT OR UPDATE ON BOOKINGS
  FOR EACH ROW
DECLARE
  l_conf_start_date CONFERENCES.FIRST_DAY%TYPE;
BEGIN
  BEGIN
    SELECT FIRST_DAY INTO l_conf_start_date
    FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_conf_start_date := NULL;
  END;

  IF (:new.BOOKING_DATE >= l_conf_start_date) THEN
    RAISE_APPLICATION_ERROR(-20016, 'Cannot add booking after the conference has started!');
  END IF;
END;


CREATE OR REPLACE TRIGGER CONF_DAY_BOOKING_ADD_CHECK_DUPLICATES_TRG
  BEFORE INSERT OR UPDATE ON CONF_DAY_BOOKINGS
  FOR EACH ROW
DECLARE
  l_conf_day_booking_count INTEGER;
BEGIN
  IF :new.IS_CANCELLED = 'N' THEN
    BEGIN
      SELECT COUNT(*) INTO l_conf_day_booking_count
      FROM CONF_DAY_BOOKINGS
      WHERE CONF_DAY_BOOKINGS.CONF_DAY_BOOKING_ID <> :new.CONF_DAY_BOOKING_ID
            AND CONF_DAY_BOOKINGS.CONF_DAY_ID = :new.CONF_DAY_ID
            AND CONF_DAY_BOOKINGS.IS_CANCELLED = 'N';
    END;

    IF (l_conf_day_booking_count > 0) THEN
      RAISE_APPLICATION_ERROR(-20016, 'Non-cancelled identical conference day booking already present!');
    END IF;
  END IF;
END;


CREATE OR REPLACE TRIGGER CONF_DAY_PARTICIPATION_STUDENT_CARD_TRG
  BEFORE INSERT OR UPDATE ON PARTICIPATION_CONF_DAYS
  FOR EACH ROW
DECLARE
  l_is_student BOOLEAN;
BEGIN
  BEGIN
    SELECT (STUDENT_CARD IS NOT NULL) INTO l_is_student
    FROM ATTENDEES
    WHERE ATTENDEES.ATTENDEE_ID = :new.ATTENDEE_ID;
  END;

  IF (:new.IS_STUDENT AND NOT l_is_student) THEN
    RAISE_APPLICATION_ERROR(-20017, 'Corresponding attendee does not have valid student card number!');
  END IF;
END;


CREATE OR REPLACE TRIGGER WORKSHOP_BOOKING_ADD_CHECK_DUPLICATES_TRG
  BEFORE INSERT OR UPDATE ON WORKSHOP_BOOKINGS
  FOR EACH ROW
DECLARE
  l_workshop_booking_count INTEGER;
BEGIN
  IF :new.IS_CANCELLED = 'N' THEN
    BEGIN
      SELECT COUNT(*) INTO l_workshop_booking_count
      FROM WORKSHOP_BOOKINGS
      WHERE WORKSHOP_BOOKINGS.WORKSHOP_BOOKING_ID <> :new.WORKSHOP_BOOKING_ID
            AND WORKSHOP_BOOKINGS.WORKSHOP_ID = :new.WORKSHOP_ID
            AND WORKSHOP_BOOKINGS.IS_CANCELLED = 'N';
    END;

    IF (l_workshop_booking_count > 0) THEN
      RAISE_APPLICATION_ERROR(-20017, 'Non-cancelled identical workshop booking already present!');
    END IF;
  END IF;
END;


CREATE OR REPLACE TRIGGER PAYMENT_BOOKING_VALUE_MATCH_TRG
  BEFORE INSERT OR UPDATE ON PAYMENTS
  FOR EACH ROW
DECLARE
  l_target_value NUMBER := BOOKING_VALUE(:new.BOOKING_ID);
BEGIN
  IF (:new.VALUE <> l_target_value) THEN
    RAISE_APPLICATION_ERROR(-20018, 'Payment value does not match booking value!');
  END IF;
END;



-- TODO: add trigger for: if conf_day_booking removed or cancelled - remove all corresponding participation
-- (and same for workshops). DONE - in procedure.
-- TODO: add trigger for: check if participation is for workshops on the same day as participation in conference day!
-- DONE - it is done by insertion method actually... that OK?