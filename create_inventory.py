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

def render_inventory(hostNames, outputFilename, groupName, template):
    try:
        j2Env = jinja2.Environment(loader=jinja2.BaseLoader())

        template = j2Env.from_string(inventoryTemplate)

        renderInventory = template.render(groupname=groupName, hostnames=hostNames)

        with open(outputFilename, 'w') as outFile:
            outFile.write(renderInventory)
        
        rResult = "Inventory " + str(outputFilename) + " geschrieben"

    except jinja2.TemplateError as jinja2Error:
        rResult = "Jinja2 Template Fehler: " + str(jinja2Error)

    except FileNotFoundError:
        rResult = "Fehler bei Schreiben von Inventoryfile " + outputFilename

    except Exception as genericError:
        rResult = "Ein generischer Fehler ist aufgetreten: " + str(genericError)
    
    return rResult

@click.command()
@click.option('--mnlist', '-m', required=True, help='List of managed Nodes', multiple=True)
@click.option('--inventoryfile', '-f', required=True, help='Name of Inventory')
@click.option('--groupname', '-g', required=True, help='Iventory groupname')
def handleArg(mnlist, inventoryfile, groupname):
    """
    Click Function Handler
    """
    #rResult=render_inventory(mnlist, inventoryfile, groupname, inventoryTemplate)
    return click.echo(render_inventory(mnlist, inventoryfile, groupname, inventoryTemplate))

def main():
    return(handleArg())

if __name__ == '__main__':
    sys.exit((main()))
