sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"fasttrackbooking/test/integration/pages/BookingSrvList",
	"fasttrackbooking/test/integration/pages/BookingSrvObjectPage",
	"fasttrackbooking/test/integration/pages/BookingItemSrvObjectPage"
], function (JourneyRunner, BookingSrvList, BookingSrvObjectPage, BookingItemSrvObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('fasttrackbooking') + '/test/flp.html#app-preview',
        pages: {
			onTheBookingSrvList: BookingSrvList,
			onTheBookingSrvObjectPage: BookingSrvObjectPage,
			onTheBookingItemSrvObjectPage: BookingItemSrvObjectPage
        },
        async: true
    });

    return runner;
});

