"""
For now script to test web client behaviour.
"""

import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.common.exceptions import TimeoutException, ElementNotVisibleException


def init_driver():
    driver = webdriver.Chrome()
    driver.wait = WebDriverWait(driver, 10)
    return driver


def lookup(driver, query):
    driver.get("http://www.google.com")
    try:
        box = driver.wait.until(ec.presence_of_element_located((By.NAME, "q")))
        button = driver.wait.until(ec.element_to_be_clickable((By.NAME, "btnK")))
        box.send_keys(query)
        try:
            button.click()
        except ElementNotVisibleException:
            button = driver.wait.until(ec.invisibility_of_element_located((By.NAME, "btnG")))
            button.click()
    except TimeoutException:
        print("Box or button not found in google.com")


if __name__ == "__main__":
    driver_obj = init_driver()
    lookup(driver_obj, "Selenium")
    time.sleep(5)
    driver_obj.quit()