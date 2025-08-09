from flask import Flask, request, render_template_string, redirect, url_for, flash, send_from_directory
import os
import uuid
from werkzeug.utils import secure_filename
from datetime import datetime

app = Flask(__name__)
app.secret_key = 'your-secret-key-here'

# Configuration
UPLOAD_FOLDER = '/data/uploads'
ALLOWED_EXTENSIONS = {'txt', 'pdf', 'png', 'jpg', 'jpeg', 'gif',
                      'doc', 'docx', 'xls', 'xlsx', 'zip', 'mp4', 'avi', 'mov'}
MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB max file size

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH

# Ensure upload directory exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def get_file_size_mb(file_path):
    size_bytes = os.path.getsize(file_path)
    return round(size_bytes / (1024 * 1024), 2)


@app.route('/')
def index():
    # List uploaded files
    files = []
    try:
        for filename in os.listdir(UPLOAD_FOLDER):
            file_path = os.path.join(UPLOAD_FOLDER, filename)
            if os.path.isfile(file_path):
                stat = os.stat(file_path)
                files.append({
                    'name': filename,
                    'size': get_file_size_mb(file_path),
                    'uploaded': datetime.fromtimestamp(stat.st_ctime).strftime('%Y-%m-%d %H:%M:%S')
                })
    except Exception as e:
        flash(f'Error listing files: {str(e)}', 'error')

    return render_template_string('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>EFS File Upload</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            h1 { color: #333; text-align: center; margin-bottom: 30px; }
            .upload-section { border: 2px dashed #ddd; padding: 30px; text-align: center; margin-bottom: 30px; border-radius: 8px; }
            .upload-section:hover { border-color: #007bff; }
            input[type="file"] { margin: 10px 0; }
            button { background-color: #007bff; color: white; padding: 12px 24px; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; }
            button:hover { background-color: #0056b3; }
            .file-list { margin-top: 30px; }
            .file-item { background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 4px; display: flex; justify-content: space-between; align-items: center; }
            .file-info { flex-grow: 1; }
            .file-name { font-weight: bold; color: #333; }
            .file-meta { color: #666; font-size: 14px; margin-top: 5px; }
            .download-btn { background-color: #28a745; padding: 8px 16px; text-decoration: none; color: white; border-radius: 4px; font-size: 14px; }
            .download-btn:hover { background-color: #1e7e34; }
            .alert { padding: 15px; margin: 20px 0; border-radius: 4px; }
            .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
            .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
            .info-box { background-color: #e7f3ff; padding: 15px; border-radius: 4px; margin-bottom: 20px; }
            .supported-formats { font-size: 14px; color: #666; margin-top: 10px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>📁 EFS File Upload System</h1>
            
            <div class="info-box">
                <strong>📊 Storage Info:</strong> Files are stored on Amazon EFS (Elastic File System) for persistent, scalable storage across multiple availability zones.
            </div>
            
            {% with messages = get_flashed_messages(with_categories=true) %}
                {% if messages %}
                    {% for category, message in messages %}
                        <div class="alert alert-{{ 'success' if category == 'success' else 'error' }}">{{ message }}</div>
                    {% endfor %}
                {% endif %}
            {% endwith %}
            
            <div class="upload-section">
                <h2>📤 Upload Files</h2>
                <form method="post" enctype="multipart/form-data" action="/upload">
                    <input type="file" name="file" multiple accept=".txt,.pdf,.png,.jpg,.jpeg,.gif,.doc,.docx,.xls,.xlsx,.zip,.mp4,.avi,.mov" required>
                    <br><br>
                    <button type="submit">Upload Files</button>
                </form>
                <div class="supported-formats">
                    <strong>Supported formats:</strong> Images (PNG, JPG, JPEG, GIF), Documents (PDF, DOC, DOCX, TXT, XLS, XLSX), Archives (ZIP), Videos (MP4, AVI, MOV)
                    <br><strong>Max file size:</strong> 16MB per file
                </div>
            </div>
            
            <div class="file-list">
                <h2>📋 Uploaded Files ({{ files|length }} files)</h2>
                {% if files %}
                    {% for file in files %}
                    <div class="file-item">
                        <div class="file-info">
                            <div class="file-name">{{ file.name }}</div>
                            <div class="file-meta">Size: {{ file.size }} MB | Uploaded: {{ file.uploaded }}</div>
                        </div>
                        <a href="/download/{{ file.name }}" class="download-btn">⬇️ Download</a>
                    </div>
                    {% endfor %}
                {% else %}
                    <p style="text-align: center; color: #666; font-style: italic;">No files uploaded yet. Upload your first file above!</p>
                {% endif %}
            </div>
        </div>
    </body>
    </html>
    ''', files=files)


@app.route('/upload', methods=['POST'])
def upload_file():
    try:
        files = request.files.getlist('file')
        if not files or all(f.filename == '' for f in files):
            flash('No files selected', 'error')
            return redirect(url_for('index'))

        uploaded_files = []
        for file in files:
            if file and file.filename != '':
                if allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    # Add timestamp to avoid conflicts
                    name, ext = os.path.splitext(filename)
                    filename = f"{name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}{ext}"

                    file_path = os.path.join(
                        app.config['UPLOAD_FOLDER'], filename)
                    file.save(file_path)
                    uploaded_files.append(filename)
                else:
                    flash(f'File type not allowed: {file.filename}', 'error')

        if uploaded_files:
            flash(
                f'Successfully uploaded {len(uploaded_files)} file(s): {", ".join(uploaded_files)}', 'success')

    except Exception as e:
        flash(f'Upload failed: {str(e)}', 'error')

    return redirect(url_for('index'))


@app.route('/download/<filename>')
def download_file(filename):
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename, as_attachment=True)
    except Exception as e:
        flash(f'Download failed: {str(e)}', 'error')
        return redirect(url_for('index'))


@app.route('/health')
def health():
    return {'status': 'healthy', 'upload_folder': UPLOAD_FOLDER}


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
