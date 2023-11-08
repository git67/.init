#!/usr/bin/env python3
# -*- coding: utf8 -*-


import os
import sys
import click
import jinja2

inventoryTemplate = """[{{ groupname }}]
{%- for host in hostnames %}
{{ host }}
{%- endfor %}

[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o GSSAPIAuthentication=no -o StrictHostKeyChecking=no'
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
@click.option('--mnlist', '-m', required=True, help='Kommaseparierte Liste der managed Nodes', type=click.STRING)
@click.option('--inventoryfile', '-f', required=True, help='Name des Inventoryfile')
@click.option('--groupname', '-g', required=True, help='Name der Iventorygruppe')
def handleArg(mnlist, inventoryfile, groupname):
    """
    Click Function Handler

    z.B.:

    # create_inventory.py -m host1,host2,host3 -g linuxnodes -f hosts
    """

    a_mnlist=mnlist.split(',')
    return click.echo(render_inventory(a_mnlist, inventoryfile, groupname, inventoryTemplate))

def main():
    return(handleArg())

if __name__ == '__main__':
    sys.exit((main()))
