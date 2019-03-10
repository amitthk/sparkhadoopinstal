import pprint
import json
import sys
import os

PATH = os.path.dirname(os.path.abspath(__file__))
INVENTORY_FILE_PATH = os.path.join(PATH,'..','ansible','hosts')
inventory_template = '''
#standalone
[masters]
{spot_hdpspark_master}

[workers]
{spot_hdpspark_worker}

[ldap]
{spot_hdpspark_master}

[kerberos]
{spot_hdpspark_master}

[db]
{spot_hdpspark_master}
'''

def parse_file(file_name):
    result = {}
    with open(file_name,'r') as tf_file:
        tf_data = json.loads(tf_file.read())
        buffer = {}
        for element in tf_data['modules']:
            buffer = {}
            buffer = element['outputs']
            resource_info = buffer.copy()
            resource_info.update(buffer)

        for key, value in resource_info.iteritems():
            result[key] = value['value']
    return result

def write_to_file(file_name,f_output):
    with open(file_name,'w') as f:
        f.write(f_output)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Usage: make_inventory.py <tfstate file name>')
        sys.exit()
    value_dict = parse_file(sys.argv[1])
    value_dict_normalized = {}
    for key, value in value_dict.items():
        if isinstance(value_dict[key],list):
            value_dict_normalized[key] = '\n'.join(value_dict[key])
        else:
            value_dict_normalized[key] = value_dict[key]
    inventory_value = str(inventory_template.format(**value_dict_normalized))
    print(inventory_value)
    write_to_file(INVENTORY_FILE_PATH,inventory_value)