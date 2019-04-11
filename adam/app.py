#!/usr/bin/python3
""" Application to record and transfer MDMA-Assited Psychotherapy Sessions"""

from flask import Flask, jsonify, render_template, request, url_for, redirect
from threading import Thread
from time import sleep
from tools import util
from mpbc import info



app = Flask(__name__)
recording = util.Recording()
default = info.Default()

def render_index():
    """
    Renders the index page with the default parameters
    """
    recording = util.Recording()
    default = info.Default()
    return render_template(
        'index.html',
        studies = info.Program.STUDIES,
        sites = info.Program.SITES,
        visits = info.Program.VISITS,
        participants = info.Program.PARTICIPANTS,
        study = default.STUDY,
        site = default.SITE,
        participant = default.PARTICIPANT,
        visit = default.VISIT,
        webcams = recording.webcams,
        microphones = recording.microphones,
        app_version = util.app_version()
    )


@app.route('/')
def index():
    return render_index()


@app.route('/start_recording', methods=['POST', 'GET'])
def start_recording():
    btn = request.args.get('btn') 
    study = request.args.get('study')
    site = request.args.get('site')
    participant = request.args.get('participant')
    visit = request.args.get('visit')
    time =  util.get_curtime()
    webcams = str(recording.webcams)
    mics = str(recording.microphones)

    default.write(study, site, participant, visit, time,  webcams, mics)

    if participant in info.Program.PARTICIPANTS and visit in info.Program.VISITS:
        if btn == 'start':
            recording.start()
            return render_template('initialize.html')
        elif btn == 'test':
            return render_template('test.html')
    else:
        return render_index()


@app.route('/confirm_recording', methods=['POST', 'GET'])
def confirm_recording():
    sleep(1)
    if recording.status() == 'RUNNING':
        return render_template('recording.html')
    else:
        return render_template('error.html')


@app.route('/stop_recording', methods=['POST', 'GET'])
def stop_recording():
    Thread(target = recording.stop).start()
    return render_index()    


def main():
    app.run()


if __name__ == '__main__': 
    main()
