CREATE TRIGGER CONF_DAY_DURING_CONFERENCE_TRG
  BEFORE INSERT OR UPDATE ON CONFERENCE_DAYS
  FOR EACH ROW
DECLARE
  day_date CONFERENCE_DAYS.DAY_DATE%TYPE;
  conf_first_day CONFERENCES.FIRST_DAY%TYPE;
  conf_last_day CONFERENCES.LAST_DAY%TYPE;
BEGIN
  day_date := :new.DAY_DATE;

  SELECT FIRST_DAY, LAST_DAY INTO conf_first_day, conf_last_day
  FROM CONFERENCES
  WHERE CONFERENCES.CONFERENCE_ID = :new.CONFERENCE_ID;

  IF NOT (day_date BETWEEN conf_first_day AND conf_last_day) THEN
    RAISE_APPLICATION_ERROR(-20000, 'The date of conference day must match the conference ' ||
                                    'start and end dates!');
  END IF;
END;

CREATE TRIGGER WORKSHOP_LIMIT_LEQ_DAY_LIMIT_TRG
  BEFORE INSERT OR UPDATE ON WORKSHOPS
  FOR EACH ROW
DECLARE
  day_limit INTEGER;
  workshops_limit INTEGER;
BEGIN
  workshops_limit := :new.LIMIT;

  SELECT LIMIT INTO day_limit
  FROM CONFERENCE_DAYS
  WHERE CONFERENCE_DAYS.CONF_DAY_ID = :new.CONF_DAY_ID;

  IF (day_limit < workshops_limit) THEN
    RAISE_APPLICATION_ERROR(-20001, 'Workshop''s people limit cannot exceed conference day''s ' ||
                                    'people limit!');
  END IF;
END;