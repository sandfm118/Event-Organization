// SPDX-License-Identifier: MIT  
// This line specifies the license under which this code is distributed (MIT License in this case)
pragma solidity ^0.8.24;           // This line defines the compatible Solidity compiler version (greater than or equal to 0.8.24)

contract EventContract {
    // This defines a new contract named 'EventContract'

    struct Event {
        // This defines a struct named 'Event' which acts like a blueprint for storing event information
        address organizer;  // Address of the event organizer
        string name;        // Name of the event
        uint date;           // Date of the event in seconds since epoch (timestamp)
        uint price;          // Price of each ticket (in Wei)
        uint ticketCount;    // Total number of tickets available for the event
        uint ticketRemain;  // Number of tickets remaining
    }

    mapping(uint => Event) public events;  // This creates a public mapping that stores events using their ID as the key and the 'Event' struct as the value

    mapping(address => mapping(uint => uint)) public tickets;  // This creates a public mapping that stores ticket ownership information. The first key is the address of the ticket holder, the second key is the event ID, and the value is the number of tickets that address holds for that event.

    uint public nextId;  // This stores the next available event ID (used for creating new events)

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        // This function allows anyone (external) to create a new event
        require(date > block.timestamp, "You can organize event for future date only.");  // Ensures event date is in the future
        require(ticketCount > 0, "You can organize event only if you create more than 0 tickets.");  // Ensures there are at least 1 ticket

        // Creates a new 'Event' instance and stores it in the 'events' mapping with the 'nextId' as the key
        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);

        // Increments the 'nextId' for the next event
        nextId++;
    }

    function buyTicket(uint id, uint quantity) external payable {
        // This function allows anyone (external) to purchase tickets for an event (payable means it accepts Ether payments)
        require(events[id].date != 0, "This Event does not exist");  // Ensures the event ID is valid
        require(block.timestamp < events[id].date, "Event has already occurred");  // Ensures the event hasn't happened yet

        // Creates a temporary storage reference to the specific event data using the ID
        Event storage _event = events[id];

        // Checks if the sent Ether amount is sufficient to cover the ticket purchase
        require(msg.value == (_event.price * quantity), "Ether is not enough");

        // Ensures there are enough tickets remaining for the requested quantity
        require(_event.ticketRemain >= quantity, "Not enough tickets");

        // Decrements the remaining tickets for the event
        _event.ticketRemain -= quantity;

        // Updates the ticket ownership mapping to reflect the purchase
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) external {
        // This function allows anyone (external) to transfer their tickets to another address
        require(events[id].date != 0, "This Event does not exist");  // Ensures the event ID is valid
        require(block.timestamp < events[id].date, "Event has already occurred");  // Ensures the event hasn't happened yet

        // Checks if the sender has enough tickets to transfer
        require(tickets[msg.sender][id] >= quantity, "You do not have enough tickets");

        // This line has a typo (extra semicolon). It should be removed.
        // tickets[msg.sender][id] >= quantity;  // This line is redundant and can be removed

        // Transfers the tickets from the sender to the recipient in the ownership mapping
        tickets[to][id] += quantity;
    }
}
