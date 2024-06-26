#!/usr/bin/env python3

import argparse
import i3ipc

# TODO(Kevin): Get these files from nix or make in /var /etc somewhere.
workspace_file = "/home/kdfrench/.config/i3/resources/workspaces.txt"
last_pose_in_workspace_file = "/home/kdfrench/.config/i3/resources/last_pose_in_workspace.txt"


def parse_args():
    """
    Parse input arguments
    """
    parser = argparse.ArgumentParser(description='Change the workspace')

    # Main arguments, used for paper's experiments
    parser.add_argument('workspace', type=str, help='name of the workspace to goto')
    parser.add_argument('-m', '--move', action='store_true', help='move the focus window')
    parser.add_argument('-f', '--follow', action='store_true',
                        help='if moving then follow the moved window')

    return parser.parse_args()


def get_ws_second_key(ws):
    key = 0
    try:
        key = int(ws.name.split(':')[1])
    except (ValueError, IndexError):
        pass
    return key


def get_ws_third_key(ws):
    key = ''
    try:
        key = ws.name.split(':')[2]
    except IndexError:
        pass
    return key

def read_last_workspace():
    last_workspace = {}
    with open(last_pose_in_workspace_file) as file:
        last_workspace = {workspace: int(num) for workspace, num in [line.strip().split(':') for line in file]}
    return last_workspace

def write_last_workspace(last_workspace):
    with open(last_pose_in_workspace_file, 'w') as file:
        for key, value in last_workspace.items():
            file.write(f'{key}:{value}\n')


if __name__ == '__main__':
    # I3 interface
    i3 = i3ipc.Connection()

    # Workspace files
    named_workspaces = []
    with open(workspace_file) as file:
        named_workspaces = [line.strip() for line in file]
    last_workspace = read_last_workspace()

    # Get workspaces and sort them
    offset = 1000
    workspaces = i3.get_workspaces()
    workspaces.sort(key=lambda ws: (ws.num, get_ws_second_key(ws)))
    current_workspace = next(filter(lambda ws: ws.focused, workspaces))
    current_ws_name = get_ws_third_key(current_workspace)
    try:
        name_index = named_workspaces.index(current_ws_name)
    except (IndexError, ValueError):
        name_index = 0
    current_named_workspaces = list(filter(lambda ws: get_ws_third_key(ws) == current_ws_name, workspaces))
    index = current_named_workspaces.index(current_workspace)

    # Pars args
    args = parse_args()

    # Handle previous
    to_name = current_workspace.name
    if args.workspace == 'prev':
        to_name = current_named_workspaces[index - 1].name
    # Handle next
    elif args.workspace == 'next':
        to_name = current_named_workspaces[(index + 1) % len(current_named_workspaces)].name
    # Handle up
    if args.workspace == 'up':
        index = (name_index - 1) % len(named_workspaces)
        name = named_workspaces[index]
        try:
            key2 = last_workspace[name]
        except KeyError:
            key2 = get_ws_second_key(current_workspace)
        to_name = '{}:{}:{}'.format(index * offset + key2, key2, name)
    # Handle down
    if args.workspace == 'down':
        index = (name_index + 1) % len(named_workspaces)
        name = named_workspaces[index]
        try:
            key2 = last_workspace[name]
        except KeyError:
            key2 = get_ws_second_key(current_workspace)
        to_name = '{}:{}:{}'.format(index * offset + key2, key2, name)
    # Handle number
    else:
        try:
            num = int(args.workspace)
            to_name = '{}:{}:{}'.format(name_index * offset + num,
                                        num,
                                        current_ws_name)
        except ValueError:
            pass

    # Save last workspace
    _, num, name = to_name.split(':')
    last_workspace[name] = num
    write_last_workspace(last_workspace)

    # Move
    if args.move:
        i3.command('move container to workspace {}'.format(to_name))
        if args.follow:
            i3.command('workspace {}'.format(to_name))
    else:
        # Switch workspace
        i3.command('workspace {}'.format(to_name))
