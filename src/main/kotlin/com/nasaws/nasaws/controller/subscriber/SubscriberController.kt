package com.nasaws.nasaws.controller.subscriber

import com.nasaws.nasaws.dtos.subscriber.SubscriberRequest
import com.nasaws.nasaws.models.Subscriber
import com.nasaws.nasaws.service.subscriber.SubscriberService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import java.net.http.HttpResponse


@RestController
@RequestMapping("/api/v1/nasaws-mailing")
class SubscriberController(
    private val subscriberService: SubscriberService
) {
    @PostMapping("/subscribe")
    fun subscribeToMailingList(
        @RequestBody subscriberRequest: SubscriberRequest
    ): ResponseEntity<Subscriber> {
        val subscriber = subscriberService.subscribeToMailingList(subscriberRequest)

        return ResponseEntity.ok(subscriber)
    }

    @DeleteMapping("/unsubscribe")
    fun deactivateMailingSubscription(
        @RequestParam email: String
    ): ResponseEntity<Void> {
        subscriberService.deactivateMailingSubscription(email)

        return ResponseEntity.noContent().build()
    }

    // @Operation(hidden = true)
    @DeleteMapping("/delete-subscription")
    fun deleteMailingSubscription(
        @RequestParam email: String
    ): ResponseEntity<Void> {
        subscriberService.deleteMailingSubscription(email)

        return ResponseEntity.noContent().build()
    }

}