CREATE TRIGGER CONF_DAY_DURING_CONFERENCE_TRG
  BEFORE INSERT OR UPDATE OF DAY_DATE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  day_date CONFERENCE_DAYS.DAY_DATE%TYPE;
  conf_first_day CONFERENCES.FIRST_DAY%TYPE;
  conf_last_day CONFERENCES.LAST_DAY%TYPE;
BEGIN
  day_date := :new.DAY_DATE;

  BEGIN
    SELECT FIRST_DAY, LAST_DAY INTO conf_first_day, conf_last_day
    FROM CONFERENCES
    WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      conf_first_day := NULL;
      conf_last_day := NULL;
  END;

  IF NOT (day_date BETWEEN conf_first_day AND conf_last_day) THEN
    RAISE_APPLICATION_ERROR(-20000, 'The date of conference day must match the conference ' ||
                                    'start and end dates!');
  END IF;
END;


CREATE TRIGGER WORKSHOP_LIMIT_LEQ_DAY_LIMIT_TRG
  BEFORE INSERT OR UPDATE OF LIMIT ON WORKSHOPS
  FOR EACH ROW
DECLARE
  day_limit INTEGER;
  workshops_limit INTEGER;
BEGIN
  workshops_limit := :new.LIMIT;

  BEGIN
    SELECT LIMIT INTO day_limit
    FROM CONFERENCE_DAYS
    WHERE CONFERENCE_DAYS.CONF_DAY_ID = :new.CONF_DAY_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      day_limit := NULL;
  END;

  IF (day_limit < workshops_limit) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Workshop''s people limit cannot exceed conference day''s ' ||
                                    'people limit!');
  END IF;
END;


CREATE TRIGGER PRICE_VALID_DATE_TRG
  BEFORE INSERT OR UPDATE OF END_DATE ON PRICES
  FOR EACH ROW
DECLARE
  thresh_end_date PRICES.END_DATE%TYPE;
  conf_start_date CONFERENCES.FIRST_DAY%TYPE;
  dupl_no NUMBER;
BEGIN
  -- Check if added threshold is not duplicate.
  thresh_end_date := :new.END_DATE;
  BEGIN
    SELECT COUNT(*) INTO dupl_no
    FROM PRICES
    WHERE CONFERENCE_ID = :new.CONFERENCE_ID
          AND END_DATE = thresh_end_date;
  END;

  IF (dupl_no > 0) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Price threshold with such date already exists!');
  ELSE
    -- Check if threshold ends before the start of the conference.
    BEGIN
      SELECT FIRST_DAY INTO conf_start_date
      FROM CONFERENCES
      WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        conf_start_date := NULL;
    END;

    IF (thresh_end_date > conf_start_date) THEN
      RAISE_APPLICATION_ERROR(-20003, 'Price threshold cannot span after the start of the conference!');
    END IF;
  END IF;
END;


CREATE TRIGGER PAYMENT_AFTER_BOOKING_TRG
  BEFORE INSERT OR UPDATE OF PAYMENT_DATE ON PAYMENTS
  FOR EACH ROW
DECLARE
  booking_date BOOKINGS.BOOKING_DATE%TYPE;
BEGIN
  BEGIN
    SELECT BOOKING_DATE INTO booking_date
    FROM BOOKINGS
    WHERE BOOKING_ID = :new.BOOKING_ID;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      booking_date := NULL;
  END;

  IF (:new.PAYMENT_DATE < booking_date) THEN
    RAISE_APPLICATION_ERROR(-20004, 'Booking date must precede payment date!');
  END IF;
END;

