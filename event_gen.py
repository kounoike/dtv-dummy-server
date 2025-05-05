import datetime

services = [x for x in range(0, 1)]

header = """<?xml version="1.0" encoding="UTF-8"?>
<tsduck>
"""

footer = """
</tsduck>
"""

print(header)

for service in services:
    start = datetime.datetime(2025, 5, 5, 0, 0, 0)
    print(f"""<EIT service_id="1" transport_stream_id="1" original_network_id="{service}" last_table_id="81">""")
    for ev in range(1001, 1101):
        start += datetime.timedelta(hours=1)
        start_time = start.strftime('%Y-%m-%d %H:%M:%S')
        print(f"""<event event_id="{ev}" start_time="{start_time}" duration="01:00:00">""")
        print(f"""<short_event_descriptor  language_code="jpn"><event_name>イベント {ev}</event_name></short_event_descriptor >""")
        print("</event>")
    print("</EIT>")
print(footer)
