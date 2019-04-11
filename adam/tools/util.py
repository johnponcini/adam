#!/usr/bin/python3
""" Utility classes and functions """

from time import strftime, gmtime
import os
import boto3
import subprocess as sp


class Recording:
    """
    Simple class for Recording
    """

    def __init__(self):
        """
        """
        self.webcams = 0
        self.microphones = 0

        devices = sp.Popen('lsusb', stdout=sp.PIPE).communicate()[0]
        for device in devices.rstrip().decode().split('\n'):
            if 'C920' in device:
                self.webcams += 1
            elif 'C-Media Electronics' in device:
                self.microphones += 1



    def start(self):
        """
        Starts a recording process
        """
        sp.Popen(['supervisorctl', 'start', 'record'], stdout=sp.PIPE)


    def status(self):
        """
        Returns the status of the recording process
        """
        child = sp.Popen(['supervisorctl', 'status', 'record'], stdout=sp.PIPE)
        status = child.communicate()[0].decode().split()[1]
        return status


    def stop(self):
        """
        Stops the recording process
        Starts the encryption process
        """
        sp.Popen(['kill', self.get_pid()], stdout=sp.PIPE)
        sp.Popen(['supervisorctl', 'stop', 'record'], stdout=sp.PIPE)
        sp.Popen(['supervisorctl', 'start', 'encrypt'], stdout=sp.PIPE)


    def get_pid(self):
        """
        Gets and returns ffmpeg pid
        """
        child = sp.Popen(['pidof', 'ffmpeg'], stdout=sp.PIPE)
        return child.communicate()[0].strip()



def get_curtime():
    return strftime("%Y%m%d-%H%M%S", gmtime())
