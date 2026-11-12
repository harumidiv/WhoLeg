import concurrent.futures
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
DEVICES = {
    'iPhone': ('62D5EE43-7123-4E55-B2A6-0D3745D6892B', None),
    'iPhone-Duo': ('579310FB-9203-4F25-A421-7D6A4859F32B', '3'),
    'iPad': ('68E3A4C3-3FF6-4E79-9426-038D7BFE7AEC', None),
}
LANGUAGES = ['en', 'de', 'fr', 'es', 'it', 'pt-BR', 'nl', 'pl', 'tr', 'zh-Hans', 'zh-Hant', 'ko', 'id', 'vi', 'th']
LOCALES = dict(zip(LANGUAGES, ['en_US','de_DE','fr_FR','es_ES','it_IT','pt_BR','nl_NL','pl_PL','tr_TR','zh_CN','zh_TW','ko_KR','id_ID','vi_VN','th_TH']))

def sim(*args, check=True):
    return subprocess.run(['xcrun', 'simctl', *args], check=check, capture_output=True, text=True)

def capture(device, language):
    udid, display = DEVICES[device]
    dest = ROOT / 'captures' / device / f'{language}.png'
    dest.parent.mkdir(parents=True, exist_ok=True)
    sim('status_bar', udid, 'override', '--time', '9:41', '--dataNetwork', 'wifi', '--wifiMode', 'active', '--wifiBars', '3', '--batteryState', 'charged', '--batteryLevel', '100')
    sim('terminate', udid, 'harumidiv.WhoLeg', check=False)
    sim('launch', udid, 'harumidiv.WhoLeg', '-AppleLanguages', f'({language})', '-AppleLocale', LOCALES[language])
    time.sleep(10)
    args = ['io', udid, 'screenshot']
    if display:
        args.append(f'--display={display}')
    sim(*args, str(dest))
    return str(dest.relative_to(ROOT))

if __name__ == '__main__':
    import sys
    languages = sys.argv[1:] or LANGUAGES
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        for language in languages:
            results = list(pool.map(lambda device: capture(device, language), DEVICES))
            print(json.dumps({'language': language, 'captures': results}), flush=True)
