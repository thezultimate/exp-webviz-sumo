from setuptools import setup, find_packages

setup(
    name="exp-webviz-sumo",
    description="Experiments with Sumo in Webviz plugins",
    packages=find_packages(),
    entry_points={
        "webviz_config_plugins": [
            "ListSurfacesPlugin = exp_webviz_sumo:ListSurfacesPlugin",
        ]
    },
    install_requires=[
        "webviz-config",
    ],
)
