assert = require "assert"
timekeeper = require "timekeeper"
request = require "request"
bond = require "bondjs"
request = require "request"
intuitClient = require "../"
config = require "./config"
intuit = intuitClient config
fixture = require "./fixtures"
process.env.TZ = "UTC"

describe "Intuit Client", ->
  describe "API", ->
    describe "institutions", ->
      before -> fixture.load "institutions"
      it "should return institutions", (done) ->
        intuit.institutions "userId", (err, institutions) =>
          assert.equal institutions.length, 20
          done err

    describe "getInstitutionDetails", ->
      before -> fixture.load "getInstitutionDetails"
      it "should return an institution's details", (done) ->
        intuit.getInstitutionDetails "userId", 100000, (err, institutionDetails) ->
          assert.equal institutionDetails.institutionName, "CCBank-Beacon"
          done err

    describe "discoverAndAddAccounts", ->
      describe "Single Factor Authentication", ->
        before -> fixture.load "discoverAndAddAccounts"
        it "should return newly created accounts", ->
          loginDetails =
            credentials:
              credential: [
                {
                  name: "Banking Userid"
                  value: "demo"
                }

                {
                  name: "Banking Password"
                  value: "go"
                }
              ]
          intuit.discoverAndAddAccounts "userId", 100000, loginDetails, (err, accounts) ->
            assert.equal accounts.length, 10
            done err

      describe "Multi Factor Authentication", ->
        before -> fixture.load "discoverAndAddAccountsMfa"
        before (done) ->
          loginDetails =
            credentials:
              credential: [
                {
                  name: "Banking Userid"
                  value: "tfa_text"
                }

                {
                  name: "Banking Password"
                  value: "go"
                }
              ]
          intuit.discoverAndAddAccounts "userId", 100000, loginDetails, (err, @mfa) =>
            done err

        it "should return a challenge node ID", ->
          assert @mfa.challengenodeid
        it "should return a challenge session ID", ->
          assert @mfa.challengesessionid
        it "should return the challenge to answer", ->
          assert @mfa.challenge

    describe "handleMfa", ->
      it "should handle challenge MFA answers"

    describe "getCustomerAccounts", ->
      before -> fixture.load "getCustomerAccounts"
      it "should return all accounts", (done) ->
        intuit.getCustomerAccounts "userId", (err, accounts) ->
          assert.equal accounts.length, 2
          done err

    describe "getAccount", ->
      before -> fixture.load "getAccount"
      it "should return an account", (done) ->
        intuit.getAccount "userId", 400107846787, (err, account) ->
          assert account.type
          done err

    describe "getAccountTransactions", ->
      describe "default parameters", ->
        before -> timekeeper.freeze new Date "2015-07-30"
        before -> fixture.load "getAccountTransactions"
        after -> timekeeper.reset()
        it "should return transactions", (done) ->
          intuit.getAccountTransactions "userId", 400107846787, (err, transactions) ->
            assert.equal transactions.length, 8
            done err

      describe "Specific start date", ->
        before -> timekeeper.freeze new Date "2015-07-30"
        before -> fixture.load "getAccountTransactions_startDate"
        after -> timekeeper.reset()
        it "should return transactions", (done) ->
          intuit.getAccountTransactions "userId", 400107846787, new Date("2015-05-15"), (err, transactions) ->
            assert.equal transactions.length, 8
            done err

      describe "Specific date range", ->
        before -> timekeeper.freeze new Date "2015-07-30"
        before -> fixture.load "getAccountTransactions_dateRange"
        after -> timekeeper.reset()
        it "should return transactions", (done) ->
          intuit.getAccountTransactions "userId", 400107846787, new Date("2015-05-15"), new Date("2015-05-22"), (err, transactions) ->
            assert.equal transactions.length, 8
            done err

    describe "updateInstitutionLogin", ->
      it "should update bank credentials"

    describe "deleteAccount", ->
      before -> fixture.load "deleteAccount"
      it "should remove the account", (done) ->
        intuit.deleteAccount "userId", 400107846793, (err, response) ->
          assert.equal response, 200
          done err

    describe "deleteCustomer", ->
      before -> fixture.load "deleteCustomer"
      it "should remove the user", (done) ->
        intuit.deleteCustomer "userId", (err, response) ->
          assert.equal response, 200
          done err
