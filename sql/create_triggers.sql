CREATE TRIGGER CONF_DAY_DURING_CONFERENCE_TRG
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


CREATE TRIGGER WORKSHOP_LIMIT_LEQ_DAY_LIMIT_TRG
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


CREATE TRIGGER PRICE_VALID_DATE_TRG
  BEFORE INSERT OR UPDATE OF END_DATE ON PRICES
  FOR EACH ROW
DECLARE
  l_thresh_end_date PRICES.END_DATE%TYPE;
  l_conf_start_date CONFERENCES.FIRST_DAY%TYPE;
  l_dupl_no NUMBER;
BEGIN
  -- Check if added threshold is not duplicate.
  l_thresh_end_date := :new.END_DATE;
  BEGIN
    SELECT COUNT(*) INTO l_dupl_no
    FROM PRICES
    WHERE CONFERENCE_ID = :new.CONFERENCE_ID
          AND END_DATE = l_thresh_end_date;
  END;

  IF (l_dupl_no > 0) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Price threshold with such date already exists!');
  ELSE
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
      RAISE_APPLICATION_ERROR(-20003, 'Price threshold cannot span after the start of the conference!');
    END IF;
  END IF;
END;


CREATE TRIGGER PAYMENT_AFTER_BOOKING_TRG
  BEFORE INSERT OR UPDATE OF PAYMENT_DATE ON PAYMENTS
  FOR EACH ROW
DECLARE
  l_booking_date BOOKINGS.BOOKING_DATE%TYPE;
BEGIN
  BEGIN
    SELECT BOOKING_DATE INTO l_booking_date
    FROM BOOKINGS
    WHERE BOOKING_ID = :new.BOOKING_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_booking_date := NULL;
  END;

  IF (:new.PAYMENT_DATE < l_booking_date) THEN
    RAISE_APPLICATION_ERROR(-20004, 'Booking date must precede payment date!');
  END IF;
END;


CREATE TRIGGER NO_CONF_DAY_DUPLICATES_TRG
  BEFORE INSERT OR UPDATE OF DAY_DATE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  l_date_count INTEGER;
BEGIN
  BEGIN
    SELECT COUNT(*) INTO l_date_count
    FROM CONFERENCE_DAYS
    WHERE DAY_DATE = :new.DAY_DATE
          AND CONFERENCE_ID = :new.CONFERENCE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date_count := NULL;
  END;

  IF (l_date_count > 0) THEN
    RAISE_APPLICATION_ERROR(-20005, 'Conference day entry for this date is already present!');
  END IF;
END;


CREATE TRIGGER WORKSHOP_CONF_DAY_DATE_MATCH_TRG
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


CREATE TRIGGER DISCOUNT_CHANGE_CHECK_PAYMENTS_TRG
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


CREATE TRIGGER CONF_DAY_PRICE_CHANGE_CHECK_PAYMENTS_TRG
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


CREATE TRIGGER CONF_DAY_LIMIT_CHANGE_CHECK_BOOKINGS_TRG
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


CREATE TRIGGER WORKSHOP_PRICE_CHANGE_CHECK_PAYMENTS_TRG
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


CREATE TRIGGER WORKSHOP_LIMIT_CHANGE_CHECK_BOOKINGS_TRG
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


CREATE TRIGGER CONFERENCE_DELETE_TRG
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


CREATE TRIGGER CONF_DAY_DELETE_CHECK_BOOKINGS_TRG
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


CREATE TRIGGER WORKSHOP_DELETE_CHECK_BOOKINGS_TRG
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