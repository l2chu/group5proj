# -*- coding: utf-8 -*-
from __future__ import print_function
import click
import os
import re
import face_recognition.api as face_recognition
import multiprocessing
import sys
import itertools


def print_result(filename, location):
    top, right, bottom, left = location
    print("{},{},{},{},{}".format(filename, top, right, bottom, left))


def test_image(image_to_check, model, upsample, name=''):
    # change: determines if user wanted to analyse a local image or an image online
    if name != '':
        unknown_image = face_recognition.load_url_file(name, url)
    else:
        unknown_image = face_recognition.load_image_file(image_to_check)
    
    face_locations = face_recognition.face_locations(unknown_image, number_of_times_to_upsample=upsample, model=model)

    for face_location in face_locations:
        print_result(image_to_check, face_location)


def image_files_in_folder(folder):
    return [os.path.join(folder, f) for f in os.listdir(folder) if re.match(r'.*\.(jpg|jpeg|png)', f, flags=re.I)]


def process_images_in_process_pool(images_to_check, number_of_cpus, model, upsample):
    if number_of_cpus == -1:
        processes = None
    else:
        processes = number_of_cpus

    # macOS will crash due to a bug in libdispatch if you don't use 'forkserver'
    context = multiprocessing
    if "forkserver" in multiprocessing.get_all_start_methods():
        context = multiprocessing.get_context("forkserver")

    pool = context.Pool(processes=processes)

    function_parameters = zip(
        images_to_check,
        itertools.repeat(model),
        itertools.repeat(upsample),
    )

    pool.starmap(test_image, function_parameters)


@click.command()
@click.argument('file_source')
@click.option('--cpus', default=1, help='number of CPU cores to use in parallel. -1 means "use all in system"')
@click.option('--model', default="hog", help='Which face detection model to use. Options are "hog" or "cnn".')
@click.option('--upsample', default=0, help='How many times to upsample the image looking for faces. Higher numbers find smaller faces.')
def main(file_source, cpus, model, upsample, name=''):  ## notice new name='' parameter ##
    # Multi-core processing only supported on Python 3.4 or greater
    if (sys.version_info < (3, 4)) and cpus != 1:
        click.echo("WARNING: Multi-processing support requires Python 3.4 or greater. Falling back to single-threaded processing!")
        cpus = 1
        
    ## change: allows for parameter 'name,' which means that the user wants to process an image from the web ##
    if name != '':
        test_image(file_source, model, upsample, name)
    else os.path.isdir(file_source):
        if cpus == 1:
            [test_image(image_file, model, upsample) for image_file in image_files_in_folder(file_source)]
        else:
            process_images_in_process_pool(image_files_in_folder(file_source), cpus, model, upsample)
    else:
        test_image(file_source, model, upsample)


if __name__ == "__main__":
    main()
