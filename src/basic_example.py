from nicegui import ui

def handle_upload(file):
    # Process the file using Pandoc
    # Convert .rst to HTML
    html_content = convert_rst_to_html(file)
    ui.output(html_content, element='iframe')  # Display the converted HTML

def convert_rst_to_html(file_in):
    print("Bingo!")

ui.label('Upload your .rst file')
# ui.file_upload(on_change=handle_upload)

ui.run()