"""Build Just Enough Items for Tinkerlands with native mod script encoding."""
import argparse
import json
from pathlib import Path
import re
import zipfile

ROOT = Path(__file__).resolve().parent
VERSION = '1.7.4'
PACKAGE_NAME = f'Just_Enough_Items_{VERSION}.zip'
LANGUAGES = ('english', 'spanish', 'french', 'german', 'portuguese', 'japanese',
             'korean', 'chinese_traditional', 'chinese_simplified', 'russian')
SCRIPTS = [('JEI@cs_jei_main', 5005, 'jei.gml'),
           ('JEI@cs_jei_on_mod_load', 5003, 'load.gml'),
           ('JEI@cs_jei_on_mod_update', 5006, 'events.gml')]


def build(destination=None, suite=None):
    assert re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)', VERSION)
    destination = Path(destination or ROOT / PACKAGE_NAME)
    destination.parent.mkdir(parents=True, exist_ok=True)
    expected = {}
    with zipfile.ZipFile(destination, 'w', zipfile.ZIP_DEFLATED) as archive:
        archive.comment = f'Just Enough Items for Tinkerlands {VERSION}'.encode()
        for key, ident, filename in SCRIPTS:
            source = (ROOT / 'src' / filename).read_text(encoding='utf-8').replace('@VERSION@', VERSION)
            if filename == 'jei.gml':
                source = '\n'.join((ROOT / 'src' / name).read_text(encoding='utf-8')
                                   for name in ('adapters.gml', 'catalog_adapter.gml', 'acquisition_adapter.gml',
                                                'input_adapter.gml', 'runtime_adapter.gml', 'text.gml', 'pinyin_data.gml', 'pinyin.gml', 'search.gml',
                                                'settings.gml', 'overlay.gml', 'catalog_draw.gml', 'overlay_draw.gml', 'overlay_tooltip.gml',
                                                'catalog_jobs.gml', 'catalog_cache.gml', 'search_jobs.gml')) + '\n' + source
            if suite and filename == 'events.gml':
                source += '\n' + suite
            source = source.replace('@VERSION@', VERSION)
            record = {'id': ident, 'key': key, 'event': 'E_CS_EVENT.None',
                      'code': source.replace(',', '#$#').replace('"', '%$%')}
            name = 'scripts/' + key + '.json'
            expected[name] = source
            archive.writestr(name, json.dumps(record, ensure_ascii=False, indent=2))
        for language in LANGUAGES:
            archive.writestr(language, '{}')
        archive.writestr('LICENSE-pypinyin.txt', (ROOT / 'third_party/LICENSE-pypinyin.txt').read_bytes())
    with zipfile.ZipFile(destination) as archive:
        assert len(archive.namelist()) == len(SCRIPTS) + len(LANGUAGES) + 1
        for name, source in expected.items():
            assert json.loads(archive.read(name))['code'].replace('#$#', ',').replace('%$%', '"') == source
        for language in LANGUAGES:
            assert isinstance(json.loads(archive.read(language)), dict)
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    print(build(args.out))
