import json

data = json.load(open('employe_fields_new.json', encoding='utf-16-le'))
fields = sorted(data['result']['fields'], key=lambda f: f['name'])

print(f"{'Field Name':<35} {'Label':<40} {'Type':<20}")
print("=" * 95)

for f in fields:
    name = f['name']
    label = f.get('label', '')
    field_type = f['type']
    print(f"{name:<35} {label:<40} {field_type:<20}")
