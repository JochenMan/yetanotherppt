from nicegui import ui

# This function will be called when the user clicks the 'Convert' button
def show_converted_html():
    # Get the text from the textarea
    text = textarea.value

    # Convert the text to HTML (implement this conversion as needed)
    converted_html = convert_to_html(text)

    # Open a new page/tab and display the converted HTML
    ui.html(converted_html)

# Create a textarea for input
textarea = ui.textarea(label='Paste your text here', placeholder='Paste text...')

# Create a button that calls the show_converted_html function when clicked
ui.button('Convert', on_click=show_converted_html)

# Function to convert the text to HTML
def convert_to_html(text):
    # Implement the conversion logic here
    # For example, you might use a library or custom code to convert the text to HTML
    # return f"<html><body>Html version of {text}</body></html>"
    multiline = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Slides Page</title>
</head>
<body>
    <h1>Welcome to the Slides Page</h1>
    <p>This is a simple static HTML page.</p>
</body>
</html>
"""
    return multiline

ui.run()