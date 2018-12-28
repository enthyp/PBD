CREATE PROCEDURE ADD_CONFERENCE(
  conf_name IN VARCHAR2,
  country IN VARCHAR2,
  city IN VARCHAR2,
  address IN VARCHAR2,
  first_day IN DATE,
  last_day IN DATE,
  student_discount IN NUMBER DEFAULT 0
) AS
BEGIN
  INSERT INTO CONFERENCES(CONFERENCE_NAME, COUNTRY, CITY, ADDRESS, FIRST_DAY, LAST_DAY, STUDENT_DISCOUNT)
    VALUES(conf_name, country, city, address, first_day, last_day, student_discount);
END;


