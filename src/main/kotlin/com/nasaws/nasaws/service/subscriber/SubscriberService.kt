package com.nasaws.nasaws.service.subscriber

import com.nasaws.nasaws.database.subscriber.SubscriberRepository
import com.nasaws.nasaws.dtos.subscriber.SubscriberRequest
import com.nasaws.nasaws.models.Subscriber
import jakarta.persistence.EntityNotFoundException
import org.springframework.stereotype.Service
import org.springframework.web.bind.annotation.RequestBody
import java.time.LocalDateTime

@Service
class SubscriberService(
    private val subscriberRepository: SubscriberRepository
) {
    fun subscribeToMailingList(
        @RequestBody subscriberRequest: SubscriberRequest
    ): Subscriber {
        val existingSubscriber = subscriberRepository.findSubscriberByEmail(subscriberRequest.email)

        return if (existingSubscriber.isPresent) {
            val subscriber = existingSubscriber.get()

            subscriber.unsubscribedAt = null
            subscriber.isActive = true

            subscriberRepository.save(subscriber)

            subscriber
        } else {
            val newSubscriber = Subscriber(
                email = subscriberRequest.email,
                unsubscribedAt = null
            )

            subscriberRepository.save(newSubscriber)

            newSubscriber
        }
    }

    fun deactivateMailingSubscription(email: String) {
        val subscriber = subscriberRepository.findSubscriberByEmail(email)
            .orElseThrow { EntityNotFoundException("Subscriber with email $email not found") }

        subscriber.unsubscribedAt = LocalDateTime.now()
        subscriber.isActive = false

        subscriberRepository.save(subscriber)
    }

    fun deleteMailingSubscription(email: String) {
        val subscriber = subscriberRepository.findSubscriberByEmail(email)
            .orElseThrow { EntityNotFoundException("Subscriber with email $email not found") }

        subscriberRepository.deleteById(subscriber.id)
    }

}