using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActivateParticles : MonoBehaviour
{
    ParticleSystem parent;
    ParticleSystem self;

    // Start is called before the first frame update
    void Start()
    {
        parent = GetComponentInParent<ParticleSystem>();
        self = GetComponent<ParticleSystem>();
    }

    // Update is called once per frame
    void Update()
    {
        if (parent.isPlaying && self.isStopped)
        {
            self.Play();
        } else if (parent.isStopped && self.isPlaying)
        {
            self.Stop();
        }
    }
}
