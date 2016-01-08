# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register "text/calendar", :ics unless Mime::Type.lookup_by_extension(:ics)
Mime::Type.register "image/jpeg", :jpg
Mime::Type.register "image/svg", :svg
Mime::Type.register "application/json", :gcal