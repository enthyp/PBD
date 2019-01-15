from faker import Factory

def delete_all_content(conn, cursor):
    cursor.execute("DELETE FROM PARTICIPATION_WORKSHOPS")
    cursor.execute("DELETE FROM WORKSHOP_BOOKINGS")
    cursor.execute("DELETE FROM WORKSHOPS")
    cursor.execute("DELETE FROM CONF_DAY_BOOKINGS")
    cursor.execute("DELETE FROM PARTICIPATION_CONF_DAYS")
    cursor.execute("DELETE FROM CONFERENCE_DAYS")
    cursor.execute("DELETE FROM PRICES")
    cursor.execute("DELETE FROM PAYMENTS")
    cursor.execute("DELETE FROM BOOKINGS")
    cursor.execute("DELETE FROM CONFERENCES")
    cursor.execute("DELETE FROM CLIENTS")
    cursor.execute("DELETE FROM ATTENDEES")
    conn.commit()

def create_conferences():
    return

# Conferences first, independent of all.
# Add conference days to each, then workshops to some of conference days.
# Add price thresholds.
# Clients next, institutional and personal separately. For personal create appropriate attendees.
# Create a bunch of attendees.
# Create bookings of clients for different conferences.
# For each booking add some conference day bookings and workshop bookings - distinguish institutional and personal -
    # - a person can only reserve one place and must give attendee data immediately.
# Finally for all the bookings add participation. Maybe map groups of attendees to conference bookings? Guess not...