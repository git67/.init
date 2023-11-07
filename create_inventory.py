#!/usr/bin/env python3
# -*- coding: utf8 -*-


import os
import sys
import json
import click
import jinja2

inventoryTemplate = """
[{{ groupname }}]
{%- for host in hostnames %}
{{ host }}
{%- endfor %}
"""

def error_message(message):
    """
    Anzeige der Fehlermeldung nach STDOUT
    Args:
    message (str): Die anzuzeigende Fehlermeldung
    """
    print(f"Error: {str(message)}")

def render_inventory(hostNames, outputFilename, groupName, template):
    try:
        j2Env = jinja2.Environment(loader=jinja2.BaseLoader())

        template = j2Env.from_string(inventoryTemplate)

        renderInventory = template.render(groupname=groupName, hostnames=hostNames)

        with open(outputFilename, 'w') as outFile:
            outFile.write(renderInventory)
        
        rResult = 0
        print(f'Inventory successfully written to {outputFilename}')

    except jinja2.TemplateError as e:
        print(f"Jinja2 template error: {e}")
        rResult = 1

    except FileNotFoundError:
        print(f"Error: Unable to open or create the file '{outputFilename}'")
        rResult = 1

    except Exception as e:
        print(f"An error occurred: {e}")
        rResult = 1

@click.command()
@click.option('--mnlist', '-m', required=True, help='List of managed Nodes', multiple=True)
@click.option('--inventoryfile', '-f', required=True, help='Name of Inventory')
@click.option('--groupname', '-g', required=True, help='Iventory groupname')
def handleArg(mnlist, inventoryfile, groupname):
    """
    Click Function Handler
    """
    return render_inventory(mnlist, inventoryfile, groupname, inventoryTemplate)

def main():
    return handleArg()


if __name__ == '__main__':
    sys.exit(main())
