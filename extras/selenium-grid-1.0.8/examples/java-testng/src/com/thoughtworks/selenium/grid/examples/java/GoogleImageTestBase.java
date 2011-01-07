package com.thoughtworks.selenium.grid.examples.java;

import static com.thoughtworks.selenium.grid.tools.ThreadSafeSeleniumSessionStorage.closeSeleniumSession;
import static com.thoughtworks.selenium.grid.tools.ThreadSafeSeleniumSessionStorage.session;
import static com.thoughtworks.selenium.grid.tools.ThreadSafeSeleniumSessionStorage.startSeleniumSession;
import static org.testng.AssertJUnit.assertTrue;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Parameters;


/**
 * Base class for all tests in Selenium Grid Java examples.
 */
public class GoogleImageTestBase {

    public static final String TIMEOUT = "120000";

    @BeforeMethod(groups = {"default", "example"}, alwaysRun = true)
    @Parameters({"seleniumHost", "seleniumPort", "browser", "webSite"})
    protected void startSession(String seleniumHost, int seleniumPort, String browser, String webSite) {
        startSeleniumSession(seleniumHost, seleniumPort, browser, webSite);
        session().setTimeout(TIMEOUT);
    }

    @AfterMethod(groups = {"default", "example"}, alwaysRun = true)
    protected void closeSession() {
        closeSeleniumSession();
    }

    protected void runScenario(String searchString) {
        session().open("/");
        assertTrue(session().getLocation(), session().getLocation().contains("images.google.com"));
        session().type("q", searchString);
        session().click("btnG");
        session().waitForPageToLoad(TIMEOUT);
        session().click("rptgl");
        session().click("imgsz_l");
        session().click("imgtype_photo");
        session().click("btnG");
        session().waitForPageToLoad(TIMEOUT);
    }

}
