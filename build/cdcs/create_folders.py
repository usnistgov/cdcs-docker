from os import makedirs
from os.path import exists, join

from django.conf import settings


folders = [settings.MEDIA_ROOT]

for folder in folders:
    if not folder:  # Ignore undefined folders
        continue

    folder_path = join(settings.BASE_DIR, folder)
    if not exists(folder_path):
        makedirs(folder_path)

    print(f"Folder {folder_path} created!")
