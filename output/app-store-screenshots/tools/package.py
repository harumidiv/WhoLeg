import hashlib
import json
from pathlib import Path
import struct
import zipfile

root = Path(__file__).resolve().parents[1]
languages = ['en', 'de', 'fr', 'es', 'it', 'pt-BR', 'nl', 'pl', 'tr', 'zh-Hans', 'zh-Hant', 'ko', 'id', 'vi', 'th']
devices = {'iPhone': (1206, 2622), 'iPhone-Duo': (2007, 2853), 'iPad': (2064, 2752)}
records = []
for language in languages:
    for device, expected in devices.items():
        for panel in ['01', '02']:
            name = f'{panel}-{expected[0]}x{expected[1]}.png'
            path = root / 'exports' / language / device / name
            data = path.read_bytes()
            assert data[:8] == b'\x89PNG\r\n\x1a\n'
            width, height, depth, color_type = struct.unpack('>IIBB', data[16:26])
            assert (width, height) == expected, path
            assert depth == 8 and color_type == 2, (path, depth, color_type)
            offset = 8
            chunks = []
            while offset < len(data):
                length = struct.unpack('>I', data[offset:offset+4])[0]
                chunks.append(data[offset+4:offset+8].decode('ascii'))
                offset += 12 + length
            assert 'tRNS' not in chunks, path
            records.append({'path': str(path.relative_to(root)), 'language': language, 'device': device, 'order': int(panel), 'width': width, 'height': height, 'color': 'RGB', 'alpha': False, 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()})
assert len(list((root / 'exports').rglob('*.png'))) == 90
assert len({r['sha256'] for r in records}) == 90
manifest = {'created': '2026-11-12', 'count': len(records), 'languages': languages, 'files': records, 'size_specification': 'https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/'}
(root / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
archive = root.parent / 'WhoLeg-AppStore-15languages-90screenshots.zip'
with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_STORED) as z:
    for record in records:
        z.write(root / record['path'], record['path'])
    for name in ['index.html', 'README.txt', 'manifest.json']:
        z.write(root / name, name)
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    assert len(z.namelist()) == 93
print(json.dumps({'verified_images': len(records), 'all_dimensions_correct': True, 'all_rgb_without_alpha': True, 'archive': str(archive), 'archive_bytes': archive.stat().st_size}))
