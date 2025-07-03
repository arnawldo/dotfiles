#!/usr/bin/env python3


import asyncio
import logging
from datetime import datetime

import iterm2

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("auto_theme")


def is_day_time():
    current_time = datetime.now().time()

    # Define morning and evening time periods in 24-hour format
    day_end = 18
    day_start = 8

    # Check the current time and determine the time of day
    if day_start < current_time.hour < day_end:
        return True
    else:
        return False


async def set_session_theme(session, preset):
    profile = await session.async_get_profile()
    await profile.async_set_color_preset(preset)


async def main(connection):
    logger.info("Start my script")
    app = await iterm2.async_get_app(connection)
    if app is None:
        logger.warning("App is None..")
        return

    color_preset_names = await iterm2.ColorPreset.async_get_list(connection)
    if (
        "GruvboxLight" not in color_preset_names
        or "GruvboxDark" not in color_preset_names
    ):
        # We only care about these themes
        logger.warning(f"Expected themes not present: {color_preset_names}")
        return

    while True:
        if is_day_time():
            logger.info(f"Will set day time theme")
            preset = await iterm2.ColorPreset.async_get(connection, "GruvboxLight")
        else:
            logger.info(f"Will set night time theme")
            preset = await iterm2.ColorPreset.async_get(connection, "GruvboxDark")

        windows = app.windows
        # For all sessions
        for window in windows:
            for tab in window.tabs:
                for session in tab.sessions:
                    await set_session_theme(session=session, preset=preset)

        # Check every 5 minutes
        await asyncio.sleep(300)


iterm2.run_forever(main)
