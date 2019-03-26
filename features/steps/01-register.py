from behave import *
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By

APP_URL = "https://account.base.vn"

@given('there is no user registered with email "{email}"')
def step_impl(context, email):
    pass

@given('there is someone registered with email "{email}"')
def step_impl(context, email):
    pass

@when('I visit url "{url}"')
def step_impl(context, url):
    context.browser = webdriver.Chrome()
    context.browser.get(APP_URL + url)
    pass

@when('I enter email with "{value}"')
def step_impl(context, value):
    element = context.browser.find_element(By.CSS_SELECTOR, '')
    element.send_keys(value)
    element.send_keys(Keys.RETURN)

@when('I enter password with "{value}"')
def step_impl(context, value):
    element = context.browser.find_element(By.CSS_SELECTOR, '')
    element.send_keys(value)
    element.send_keys(Keys.RETURN)

@then('I should see a dialog with message "{message}"')
def step_impl(context, element_id, message):
    wait = WebDriverWait(context.browser, 10)
    wait.until(lambda x: x.find_element_by_id(element_id).is_displayed())
    element = context.browser.find_element_by_id(element_id)
    assert message in element.text
