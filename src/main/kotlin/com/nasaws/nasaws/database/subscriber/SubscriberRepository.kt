package com.nasaws.nasaws.database.subscriber

import com.nasaws.nasaws.models.Subscriber
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import java.util.*

@Repository
interface SubscriberRepository : JpaRepository<Subscriber, Long> {

    fun findByEmailIn(subscriberEmails: List<String>): Optional<List<Subscriber>>

    fun findSubscriberByEmail(email: String): Optional<Subscriber>


}