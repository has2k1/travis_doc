"""
Travis Built Documentation

Test project where documentation is built by Travis CI and
pushed to gh-pages.
"""

from setuptools import setup, find_packages

import versioneer

__author__ = 'Hassan Kibirige'
__email__ = 'has2k1@gmail.com'
__description__ = "Travis CI builds documentation for gh-pages"
__license__ = 'BSD (3-clause)'
__url__ = 'https://github.com/has2k1/travis_doc'


def check_dependencies():
    """
    Check for system level dependencies
    """
    pass


def get_required_packages():
    """
    Return required packages

    Plus any version tests and warnings
    """
    install_requires = []
    return install_requires


def get_package_data():
    """
    Return package data

    For example:

        {'': ['*.txt', '*.rst'],
         'hello': ['*.msg']}

    means:
        - If any package contains *.txt or *.rst files,
          include them
        - And include any *.msg files found in
          the 'hello' package, too:
    """
    return {}


if __name__ == '__main__':

    check_dependencies()

    setup(name='travis_doc',
          maintainer=__author__,
          maintainer_email=__email__,
          description=__description__,
          long_description=__doc__,
          license=__license__,
          version=versioneer.get_version(),
          cmdclass=versioneer.get_cmdclass(),
          url=__url__,
          install_requires=get_required_packages(),
          packages=find_packages(),
          package_data=get_package_data(),
          classifiers=[
              'Intended Audience :: Science/Research',
              'License :: OSI Approved :: BSD License',
              'Programming Language :: Python :: 2',
              'Programming Language :: Python :: 3',
              'Topic :: Scientific/Engineering :: Visualization',
          ],
          )
