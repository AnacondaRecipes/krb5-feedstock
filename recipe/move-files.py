#!/usr/bin/env python3
import os
import shutil
import glob

def move_files():
    """Move files to appropriate locations for packaging."""
    prefix = os.environ.get('PREFIX', '')
    if not prefix:
        return
    
    # Create staging directories
    staging_dir = os.path.join(prefix, 'staging')
    os.makedirs(staging_dir, exist_ok=True)
    
    # Move executables to staging (they will go to krb5 package)
    bin_dir = os.path.join(prefix, 'bin')
    if os.path.exists(bin_dir):
        for exe in ['kinit', 'klist', 'kdestroy', 'kpasswd', 'kswitch', 'ktutil', 
                   'kvno', 'k5srvutil', 'kadmin', 'gss-client', 'sclient', 
                   'sim_client', 'uuclient', 'ksu', 'krb5-config']:
            exe_path = os.path.join(bin_dir, exe)
            if os.path.exists(exe_path):
                staging_exe_dir = os.path.join(staging_dir, 'bin')
                os.makedirs(staging_exe_dir, exist_ok=True)
                shutil.move(exe_path, os.path.join(staging_exe_dir, exe))
    
    # Move server utilities to staging
    sbin_dir = os.path.join(prefix, 'sbin')
    if os.path.exists(sbin_dir):
        for exe in ['kadmin.local', 'kadmind', 'kdb5_util', 'kprop', 'kpropd', 
                   'kproplog', 'krb5kdc', 'krb5-send-pr', 'gss-server', 
                   'sim_server', 'sserver', 'uuserver']:
            exe_path = os.path.join(sbin_dir, exe)
            if os.path.exists(exe_path):
                staging_sbin_dir = os.path.join(staging_dir, 'sbin')
                os.makedirs(staging_sbin_dir, exist_ok=True)
                shutil.move(exe_path, os.path.join(staging_sbin_dir, exe))
    
    # Move manual pages to staging
    share_dir = os.path.join(prefix, 'share')
    if os.path.exists(share_dir):
        man_dir = os.path.join(share_dir, 'man')
        if os.path.exists(man_dir):
            staging_man_dir = os.path.join(staging_dir, 'share', 'man')
            os.makedirs(staging_man_dir, exist_ok=True)
            
            # Move man1 pages for executables
            man1_dir = os.path.join(man_dir, 'man1')
            if os.path.exists(man1_dir):
                staging_man1_dir = os.path.join(staging_man_dir, 'man1')
                os.makedirs(staging_man1_dir, exist_ok=True)
                for man in ['kinit.1', 'klist.1', 'kdestroy.1', 'kpasswd.1', 
                           'kswitch.1', 'ktutil.1', 'kvno.1', 'k5srvutil.1', 
                           'kadmin.1', 'sclient.1', 'ksu.1', 'krb5-config.1']:
                    man_path = os.path.join(man1_dir, man)
                    if os.path.exists(man_path):
                        shutil.move(man_path, os.path.join(staging_man1_dir, man))
            
            # Move man8 pages for server utilities
            man8_dir = os.path.join(man_dir, 'man8')
            if os.path.exists(man8_dir):
                staging_man8_dir = os.path.join(staging_man_dir, 'man8')
                os.makedirs(staging_man8_dir, exist_ok=True)
                for man in ['kadmin.local.8', 'kadmind.8', 'kdb5_util.8', 
                           'kprop.8', 'kpropd.8', 'kproplog.8', 'krb5kdc.8', 
                           'sserver.8', 'kdb5_ldap_util.8']:
                    man_path = os.path.join(man8_dir, man)
                    if os.path.exists(man_path):
                        shutil.move(man_path, os.path.join(staging_man8_dir, man))

if __name__ == '__main__':
    move_files() 