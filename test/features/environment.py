"""
This environment file serves as the basis for our Behave runs when
testing our Terraform modules.
.../as-aws-module/test/features/environment.py
"""
import boto3
import os
import pprint
import subprocess
import sys
import time

from configparser import (
    ConfigParser,
    ExtendedInterpolation,
    NoSectionError
)

from sdg.test.behave import (
    core, 
    web
)

MODULES = [
    web
]

def project_dir():
    ''' Find the project dir '''
    cwd = os.getcwd()

    while(True):
        for f in os.scandir('.'):
            if f.name == '.git' and f.is_dir():
                r = os.getcwd() 
                os.chdir(cwd)     
                return r

        if os.getcwd() != '/':
            os.chdir("..")
        else:
            break

 
DIR = os.path.abspath(os.path.dirname(__file__))
PROJECT_DIR = project_dir()
CONF_DIR = os.path.normpath(os.path.join(PROJECT_DIR, "test", "config"))

CONFIG = ConfigParser(interpolation=ExtendedInterpolation())
CONFIG.optionxform = str

DEBUG = False
DISABLE_DOCKER_UP = False
DISABLE_DOCKER_DOWN = False

def find_configs(top_dir, bottom_dir):
    ''' Find the config from project dir to bottom '''
    cwd_save = os.getcwd()
    dirs = list()   

    os.chdir(bottom_dir)
    while(True):
        for f in os.scandir('.'):
            if f.name == 'config.ini' and f.is_file():
                dirs.append(os.path.abspath(f.path))

        cwd = os.getcwd()
        if cwd == '/' or cwd == top_dir:
            break
        else:
            os.chdir("..")

    os.chdir(cwd_save)    
    return dirs


def load_configs(config, top_dir, bottom_dir):
    paths = find_configs(top_dir, bottom_dir)

    while paths:
        config.read(paths.pop())


CONFIG.add_section('env')
CONFIG['env'].update(os.environ)
load_configs(CONFIG, PROJECT_DIR, DIR)


def check_aws_credentials():
    ''''''
    try:
        boto3.client('sts').get_caller_identity()
    except:
        print("\n\n#####################")
        print("Currenlty selected AWS credentials are invalid!")
        print("#####################")
        exit(1)


def before_all(context):
    """Set required module variables."""
    check_aws_credentials()

    global DEBUG, DISABLE_DOCKER_UP, DISABLE_DOCKER_DOWN

    DEBUG = context.config.userdata.getbool("DEBUG")
    DISABLE_DOCKER_UP = context.config.userdata.getbool("DISABLE_DOCKER_UP")
    DISABLE_DOCKER_DOWN = context.config.userdata.getbool("DISABLE_DOCKER_DOWN")
    
    core.INIT_ENV(context, MODULES)
    core.SET_REQ_VARS(context,
        project_root=PROJECT_DIR,
        test_root=DIR)

    if not DISABLE_DOCKER_UP and not disable_docker():    
        p = subprocess.Popen(['docker-compose', 'up', '-d', '--no-recreate'],
            cwd=DIR, env=CONFIG['env'])
        p.wait()
        time.sleep(5)


def before_feature(context, feature):
    # Adding config ini to be used in Behave features
    for section_name in CONFIG.sections():
        section_data = dict(CONFIG.items(section=section_name))
        section = context.core.CONFIG['MASTER'].get(section_name, {})
        section.update(section_data)
        context.core.CONFIG['MASTER'][section_name] = section


def after_all(context):
    """Clean up environment"""
    global DISABLE_DOCKER_DOWN

    if not DISABLE_DOCKER_DOWN and not disable_docker():    
        p = subprocess.Popen(['docker-compose', 'down'], cwd=DIR)
        p.wait()


def after_step(context, step):
    ''''''
    global DISABLE_DOCKER_DOWN

    if DEBUG and step.status == "failed":
       DISABLE_DOCKER_DOWN = True

	
def disable_docker():
    '''''' 
    try:
        return CONFIG.getboolean('Test Config', 'DISABLE_DOCKER_COMPOSE') 
    except NoSectionError:
        return False




def main():
    pass


if __name__ == '__main__':
    main()
    
